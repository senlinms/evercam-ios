//
//  WelcomeViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
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

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (IBAction)StoryBoardButton_Pressed:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"myViewController"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
    
}




- (void)viewDidLoad {
    [super viewDidLoad]; 
    
    [self.view setHidden:YES];
    
    self.navigationController.navigationBarHidden = YES;    
    self.screenName = @"Welcome Page";
    // Do any additional setup after loading the view from its nib.
    self.title = @"";
    [self.tutorialScrollView addSubview:self.tutorialView];
    
    if ([GlobalSettings sharedInstance].isPhone == YES) {
        self.tutorialView.frame = CGRectMake(0, (self.tutorialScrollView.bounds.size.height-self.tutorialView.bounds.size.height)/2, self.tutorialView.bounds.size.width, self.tutorialView.frame.size.height);
        [self.tutorialScrollView setContentSize:CGSizeMake(960,self.tutorialScrollView.frame.size.height)];
    }
    else {
        self.tutorialView.frame = CGRectMake(0, 0, self.tutorialView.frame.size.width, self.tutorialView.frame.size.height);
        [self.tutorialScrollView setContentSize:CGSizeMake(self.view.frame.size.width * 3, 0)];
    }
    
    
    AppUser *defaultUser = [APP_DELEGATE getDefaultUser];
    if (defaultUser) {
        [APP_DELEGATE setDefaultUser:defaultUser];
        
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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
