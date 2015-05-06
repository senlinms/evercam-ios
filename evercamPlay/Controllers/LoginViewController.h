//
//  LoginViewController.h
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface LoginViewController : GAITrackedViewController
@property (nonatomic, retain) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_password;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *btn_Signup;

- (IBAction)onLogin:(id)sender;
- (IBAction)onBack:(id)sender;

@end
