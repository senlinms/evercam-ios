//
//  RecordingsViewController.m
//  evercamPlay
//
//  Created by jw on 4/16/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "RecordingsViewController.h"
#import "EvercamApiKeyPair.h"
#import "EvercamShell.h"

@interface RecordingsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation RecordingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRecordingWidget];
    self.screenName = @"Recordings";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadRecordingWidget {
    EvercamApiKeyPair *keyPair = [EvercamShell shell].keyPair;
    NSString *customHtml = [NSString stringWithFormat:@"<html><body style='margin:0;padding:0;'><div evercam=\"snapshot-navigator\"></div><script type=\"text/javascript\" src=\"https://dashboard.evercam.io/snapshot.navigator.js?camera=%@&private=false&api_id=%@&api_key=%@\"></script></body></html>",
                            self.cameraId,
                            keyPair.apiId,
                            keyPair.apiKey];
    [self.webView loadHTMLString:customHtml baseURL:nil];
}

#pragma mark - UIWebView Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.loadingView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.loadingView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.loadingView stopAnimating];
}

@end
