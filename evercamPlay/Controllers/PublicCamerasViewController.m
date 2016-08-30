//
//  PublicCamerasViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/20/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "PublicCamerasViewController.h"

@interface PublicCamerasViewController ()

@end

@implementation PublicCamerasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.loading_ActivityIndicator startAnimating];
    self.cameras_WebView.hidden = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://evercam.io/public/cameras"]];
    [self.cameras_WebView loadRequest:request];
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

- (IBAction)back_Action:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma UIWEBVIEW DELEGATES

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.loading_ActivityIndicator startAnimating];
    self.cameras_WebView.userInteractionEnabled = NO;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.loading_ActivityIndicator stopAnimating];
    self.cameras_WebView.hidden = NO;
    self.cameras_WebView.userInteractionEnabled = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self.loading_ActivityIndicator stopAnimating];
    self.cameras_WebView.userInteractionEnabled = YES;
    
}

@end
