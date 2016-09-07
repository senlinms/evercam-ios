//
//  LoginViewController.h
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GravatarServiceFactory.h"

@interface LoginViewController : GAITrackedViewController<GravatarServiceDelegate>{
    BOOL isFromAddAccount;
}

@property (nonatomic,assign) BOOL isFromAddAccount;

@property (nonatomic, retain) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *btn_Signup;

- (IBAction)onLogin:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onForgotPassword:(id)sender;

@end
