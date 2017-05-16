//
//  SignupViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "SignupViewController.h"
#import "EvercamUser.h"
#import "EvercamShell.h"
#import "LoginViewController.h"
#import "CamerasViewController.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "EvercamApiKeyPair.h"
#import "MenuViewController.h"
#import "Config.h"
#import "GlobalSettings.h"
#import "Mixpanel.h"
#import "PreferenceUtil.h"
#import "Intercom/intercom.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "ForgotPasswordViewController.h"
@import Firebase;

@interface SignupViewController ()
{
    UITextField *activeTextField;
}

@end

@implementation SignupViewController
@synthesize isFromAddAccountScreen;
- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Do any additional setup after loading the view from its nib.
    [self.contentView contentSizeToFit];


    if ([self.txt_username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor blackColor];
        self.txt_firstname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_lastname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
//        self.txt_confirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];

}

-(void)viewDidLayoutSubviews{
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.contentView contentSizeToFit];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

#pragma mark Validation 
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (IBAction)termofUseAction:(id)sender {
    ForgotPasswordViewController *fVc = [[ForgotPasswordViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ?@"ForgotPasswordViewController":@"ForgotPasswordViewController_iPad" bundle:[NSBundle mainBundle]];
    fVc.isTermofUse                     = YES;
    [self.navigationController pushViewController:fVc animated:YES];
}

- (IBAction)onCreateAccount:(id)sender
{
    EvercamUser *user = [EvercamUser new];
    NSString *firstname = _txt_firstname.text;
    NSString *lastname = _txt_lastname.text;
    NSString *email = _txt_email.text;
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;
//    NSString *repassword = _txt_confirmPassword.text;
    /*
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLog(@"countryCode:%@", countryCode);
    */
    NSRange whiteSpaceRange = [username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    // firstname
    if ([firstname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"First name required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 101;
        [simpleAlert show];
        return;
    }
    else
    {
        user.firstname = firstname;
    }
    
    // lastname
    if ([lastname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Last name required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 102;
        [simpleAlert show];
        
        return;
    }
    else
    {
        user.lastname = lastname;
    }

    // username
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Username required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 103;
        [simpleAlert show];
        
        return;
    }
    else if (whiteSpaceRange.location != NSNotFound)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Invalid username", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 104;
        [simpleAlert show];
        
        return;
    }
    else if (username.length < 3)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Username is too short", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 105;
        [simpleAlert show];
        
        return;
    }
    else
    {
        user.username = username;
    }
    /*
    // country
    user.country = countryCode;
    */
    // email
    if ([email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Email required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 106;
        [simpleAlert show];
        
        return;
    }
    else if ([self NSStringIsValidEmail:email] == NO)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Email required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 107;
        [simpleAlert show];
        
        return;
    }
    else
    {
        user.email = email;
    }
    
    // Password 
    if (password.length <= 0 || password.length < 6)
    {
        NSString *message = (password.length <= 0)?@"Password required":@"Password should be at least 6 character(s).";
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(message, nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 108;
        [simpleAlert show];
        
        return;
    }
    /*
    else if (repassword.length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Confirm password required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 109;
        [simpleAlert show];
        
        return;
    }
    
    else if ([password isEqualToString:repassword] == NO)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Password not match", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        
        return;
    }
    */
    else if ([password rangeOfString:@" "].location != NSNotFound) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Password should not contain space", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return;
    }
    else
    {
        user.password = password;
    }

    [_activityIndicator startAnimating];
    [[EvercamShell shell] createUser:user WithBlock:^(EvercamUser *nwuser, NSError *error) {
        [_activityIndicator stopAnimating];
        if (error == nil)
        {
            if (nwuser)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [_activityIndicator startAnimating];
                    [[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
                        if (error == nil)
                        {
                            [[EvercamShell shell] getUserFromId:username withBlock:^(EvercamUser *newuser, NSError *error) {
                                [_activityIndicator stopAnimating];
                                if (error == nil) {
                                    
                                    //clear intercom at logout
                                    [Intercom reset];
                                    
                                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                    
                                    [mixpanel identify:newuser.username];
                                    [mixpanel.people set:@{@"$first_name": newuser.firstname,
                                                           @"$last_name": newuser.lastname,
                                                           @"Username": newuser.username,
                                                           @"$email": newuser.email}];
                                    
                                    [mixpanel identify:newuser.username];
                                    
                                    [mixpanel track:mixpanel_event_sign_up properties:@{
                                                                                        @"Client-Type": @"Play-iOS"
                                                                                        }];
                                    
                                    AppUser *user = [APP_DELEGATE userWithName:newuser.username];
                                    [user setDataWithEvercamUser:newuser];
                                    [user setApiKeyPairWithApiKey:userKeyPair.apiKey andApiId:userKeyPair.apiId];
                                    [APP_DELEGATE saveContext];
                                    [APP_DELEGATE setDefaultUser:user];
                                    
                                    //Registering user with Intercom
                                    [Intercom registerUserWithUserId:newuser.username];
                                
                                    [FIRAnalytics logEventWithName:kFIREventSignUp parameters:@{ kFIRParameterSignUpMethod:action_signup_success}];
                                    
                                    [FIRAnalytics logEventWithName:@"Evercam_Signed_Up"
                                                        parameters:@{
                                                                     @"Evercam_User_Name": newuser.username,
                                                                     @"Evercam_Email": newuser.email
                                                                     }];
                                    
                                    if (isFromAddAccountScreen) {
                                        [self.navigationController popToRootViewControllerAnimated:YES];
                                        return;
                                    }
                                    
                                    CamerasViewController *camerasViewController = [[CamerasViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"CamerasViewController" : @"CamerasViewController_iPad" bundle:nil];
                                    MenuViewController *menuViewController = [[MenuViewController alloc] init];
                                    
                                    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:camerasViewController];
                                    frontNavigationController.navigationBarHidden = YES;
                                    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
                                    rearNavigationController.navigationBarHidden = YES;
                                    
                                    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
                                    NSMutableArray *vcArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                                    [vcArr removeLastObject];
                                    [vcArr addObject:revealController];
                                    [self.navigationController setViewControllers:vcArr animated:YES];
                                    
                                    [PreferenceUtil setIsShowOfflineCameras:YES];
                                    
                                    // show successful message
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Congratulations, you're now logged in with your Evercam account.\n\nWe've added a demo camera for you - add your own from the menu" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alertView show];
                                    
                                } else {
                                    NSLog(@"Error %li: %@", (long)error.code, error.description);
                                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                    [simpleAlert show];
                                }
                            }];
                            
                        }
                        else
                        {
                            [_activityIndicator stopAnimating];
                            NSLog(@"Error %li: %@", (long)error.code, error.description);
                            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [simpleAlert show];
                        }
                    }];
                });
            }
        }
        else
        {
            NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [simpleAlert show];
            });
        }
    }];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.txt_firstname)
    {
        [self.txt_lastname becomeFirstResponder];
    }
    else if (textField == self.txt_lastname)
    {
        [self.txt_username becomeFirstResponder];
    }
    else if (textField == self.txt_username)
    {
        [self.txt_email becomeFirstResponder];
    }
    else if (textField == self.txt_email)
    {
        [self.txt_password becomeFirstResponder];
    }
    else if (textField == self.txt_password)
    {
        [self.txt_confirmPassword becomeFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}


#pragma mark - UITapGesture Recognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [activeTextField resignFirstResponder];
}

#pragma mark UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) {
        [_txt_firstname becomeFirstResponder];
    }
    else if (alertView.tag == 102) {
        [_txt_lastname becomeFirstResponder];
    }
    else if (alertView.tag == 103 ||alertView.tag == 104 || alertView.tag == 105) {
        [_txt_username becomeFirstResponder];
    }
    else if (alertView.tag == 106 || alertView.tag == 107) {
        [_txt_email becomeFirstResponder];
    }
    else if (alertView.tag == 108) {
        [_txt_password becomeFirstResponder];
    }
    else if (alertView.tag == 109) {
        [_txt_confirmPassword becomeFirstResponder];
    }
}

@end
