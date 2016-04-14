//
//  ForgotPasswordViewController.m
//  evercamPlay
//
//  Created by NainAwan on 13/04/2016.
//  Copyright © 2016 Evercam. All rights reserved.
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.process_ActivityIndicator startAnimating];
    self.password_WebView.hidden = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dash.evercam.io/v1/users/password-reset"]];
    [self.password_WebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma UIWEBVIEW DELEGATES

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.process_ActivityIndicator startAnimating];
    self.password_WebView.userInteractionEnabled = NO;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.process_ActivityIndicator stopAnimating];
    self.password_WebView.hidden = NO;
    self.password_WebView.userInteractionEnabled = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self.process_ActivityIndicator stopAnimating];
    self.password_WebView.userInteractionEnabled = YES;
    
}

@end
