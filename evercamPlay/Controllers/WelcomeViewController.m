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

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"";
    [self.tutorialScrollView addSubview:self.tutorialView];
    self.tutorialView.center = CGPointMake(480, self.tutorialScrollView.frame.size.height/2);
    [self.tutorialScrollView setContentSize:CGSizeMake(960,self.tutorialScrollView.frame.size.height)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSignIn:(id)sender
{
    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle: nil];
    [[self navigationController] pushViewController:vc animated:YES];
}

- (IBAction)onSignUp:(id)sender
{
    SignupViewController *vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle: nil];
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
