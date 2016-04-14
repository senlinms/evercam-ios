//
//  FeedbackViewController.m
//  EvercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "NetworkUtil.h"

@interface AboutViewController ()
{
    BOOL isWebLoaded;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.screenName = @"About Page";
    isWebLoaded = NO;
    // Do any additional setup after loading the view from its nib.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.evercam.io"]]];
}

-(void)viewWillAppear:(BOOL)animated{
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

- (IBAction)BackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //    [self.activity startAnimating];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activity stopAnimating];
    isWebLoaded = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activity stopAnimating];
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ops!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    //    [alertView show];
    //    return;
}


@end