//
//  ForgotPasswordViewController.h
//  evercamPlay
//
//  Created by NainAwan on 13/04/2016.
//  Copyright © 2016 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController<UIWebViewDelegate>{
    
}
- (IBAction)backAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *password_WebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *process_ActivityIndicator;

@end
