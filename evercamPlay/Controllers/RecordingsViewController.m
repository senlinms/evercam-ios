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
    [self.loadingView startAnimating];
    self.webView.hidden             = YES;
    [self loadRecordingWidget];
    self.screenName                 = @"Cloud Recordings";
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
    NSString *customHtml = [NSString stringWithFormat:@"<html><body style='margin:0;padding:0;'><div evercam=\"snapshot-navigator\"></div><script type=\"text/javascript\" src=\"https://dash.evercam.io/snapshot.navigator.js?camera=%@&private=false&api_id=%@&api_key=%@\"></script></body></html>",
                            self.cameraId,
                            keyPair.apiId,
                            keyPair.apiKey];
    [self.webView loadHTMLString:customHtml baseURL:nil];
}

#pragma UIWEBVIEW DELEGATES

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSRange stringRange = [[[request URL] absoluteString] rangeOfString:@"data:image/jpeg;base64,"];
    if(stringRange.location != NSNotFound){
        NSString *imageString = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@""];
        UIImage *image = [self decodeBase64ToImage:imageString];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self.loadingView startAnimating];
    self.webView.userInteractionEnabled = NO;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.loadingView stopAnimating];
    self.webView.hidden = NO;
    self.webView.userInteractionEnabled = YES;
    webView.scrollView.delegate = self; // set delegate method of UISrollView
    webView.scrollView.maximumZoomScale = 20; // set as you want.
    webView.scrollView.minimumZoomScale = 1; // set as you want.
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self.loadingView stopAnimating];
    self.webView.userInteractionEnabled = YES;
    
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
    if (error)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return;
    }
    else
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Export Image", nil) message:@"The image has exported to your photo album successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    self.webView.scrollView.maximumZoomScale = 20; // set similar to previous.
}

@end
