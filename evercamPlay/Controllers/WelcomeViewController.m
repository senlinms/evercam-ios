//
//  WelcomeViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "AppUser.h"
#import "AppDelegate.h"
#import "CamerasViewController.h"
#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import "GlobalSettings.h"
#import "Intercom/intercom.h"

@interface WelcomeViewController (){
    MPMoviePlayerController *playercontroller;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setHidden:YES];
    AppUser *loginUser = [APP_DELEGATE getDefaultUser];
    if (!loginUser) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playIntroVideo) name:UIApplicationDidBecomeActiveNotification object:nil];
    }


    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view from its nib.
    self.title = @"";
    self.signInbtn.layer.cornerRadius   = 1.0;
    self.accountBtn.layer.cornerRadius  = 1.0;
    
    AppUser *defaultUser = [APP_DELEGATE getDefaultUser];
    if (defaultUser) {
        [APP_DELEGATE setDefaultUser:defaultUser];
        
        //registering user with Intercom
        [Intercom registerUserWithUserId:defaultUser.username];
        
        CamerasViewController *camerasViewController = [[CamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CamerasViewController" : @"CamerasViewController_iPad" bundle:nil];
        MenuViewController *menuViewController = [[MenuViewController alloc] init];
        
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:camerasViewController];
        frontNavigationController.navigationBarHidden = YES;
        UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
        rearNavigationController.navigationBarHidden = YES;
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
        revealController.navigationController.navigationBarHidden = YES;
        NSMutableArray *vcArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [vcArr addObject:revealController];
        [self.navigationController setViewControllers:vcArr animated:YES];
        
        [self performSelector:@selector(showView) withObject:nil afterDelay:3];
    }
    else
        [self.view setHidden:NO];
}


- (void)showView
{
    [self.view setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppUser *defaultUser = [APP_DELEGATE getDefaultUser];
    if (!defaultUser) {
        [self playIntroVideo];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:playercontroller];
    [playercontroller stop];
    playercontroller = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Movie Playing
-(void)playIntroVideo{
    
    if (!playercontroller) {
        NSLog(@"Player instance intialized.");
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gpoview" ofType:@"mp4"]];
        playercontroller = [[MPMoviePlayerController alloc] initWithContentURL:url];
        playercontroller.controlStyle = MPMovieControlStyleNone;
        playercontroller.scalingMode = MPMovieScalingModeAspectFill;
        //Set to parent bounds
        [playercontroller.view setFrame:self.playerContainerView.bounds];
        [self.playerContainerView addSubview:playercontroller.view];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:playercontroller];
    [playercontroller play];
    
}

- (void)videoPlayDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    if (notification.object == player) {
        NSLog(@"%@",notification.userInfo);
        NSInteger reason = [[notification.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
        if (reason == MPMovieFinishReasonPlaybackEnded) {
            [self performSelector:@selector(playIntroVideo) withObject:nil afterDelay:0.5];
        }
    }
}


- (IBAction)onSignIn:(id)sender
{
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"LoginViewController" : @"LoginViewController_iPad" bundle: nil];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (IBAction)onSignUp:(id)sender
{
    SignupViewController *vc = [[SignupViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SignupViewController" : @"SignupViewController_iPad" bundle: nil];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (IBAction)changePage:(id)sender {
    CGFloat x = self.pageControl.currentPage * self.tutorialScrollView.frame.size.width;
    [self.tutorialScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isDecelerating){
        self.pageControl.currentPage = lround(self.tutorialScrollView.contentOffset.x / (self.tutorialScrollView.contentSize.width / self.pageControl.numberOfPages));
    }
}
@end
