//
//  SignupViewController.h
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIDropDown.h"
#import "GAI.h"
@class TPKeyboardAvoidingScrollView;
@interface SignupViewController : GAITrackedViewController <NIDropDownDelegate>{
    BOOL isFromAddAccountScreen;
}

@property (nonatomic,assign) BOOL isFromAddAccountScreen;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *txt_firstname;
@property (nonatomic, strong) IBOutlet UITextField *txt_lastname;
@property (nonatomic, strong) IBOutlet UIButton *btn_country;
@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_email;
@property (nonatomic, strong) IBOutlet UITextField *txt_password;
@property (nonatomic, strong) IBOutlet UITextField *txt_confirmPassword;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)onCreateAccount:(id)sender;
@end
