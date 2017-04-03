//
//  LoginViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "MenuViewController.h"
#import "CamerasViewController.h"
#import "SignupViewController.h"
#import "EvercamShell.h"
#import "AppUser.h"
#import "EvercamUser.h"
#import "EvercamApiKeyPair.h"
#import "AppDelegate.h"
#import "GlobalSettings.h"
#import "Mixpanel.h"
#import "Config.h"
#import "ForgotPasswordViewController.h"
#import "Intercom/intercom.h"
#import "EvercamUtility.h"

@interface LoginViewController ()
{
    UITextField *activeTextField;
    BOOL isPasswordHidden;
    
}
@end

@implementation LoginViewController
@synthesize isFromAddAccount;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_4) {
        self.contentView.contentSize = CGSizeMake(self.contentView.frame.size.width, 548.0);
    }else{
        self.contentView.contentSize = self.contentView.bounds.size;
    }
    
    
    if ([self.txt_username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightGrayColor];
        self.txt_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email/Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)viewDidLayoutSubviews{
    
}

- (IBAction)onLogin:(id)sender
{
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;
    
    NSRange whiteSpaceRange = [username rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Username required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 101;
        [simpleAlert show];
        
        return;
    }
    else if (whiteSpaceRange.location != NSNotFound)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Invalid username", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 102;
        [simpleAlert show];
        
        return;
    }
    else if (password.length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:NSLocalizedString(@"Password required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 103;
        [simpleAlert show];
        return;
    }
    
    [self.txt_username resignFirstResponder];
    [self.txt_password resignFirstResponder];
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
                    [mixpanel track:mixpanel_event_sign_in properties:@{
                                                                        @"Client-Type": @"Play-iOS",
                                                                        }];
                    
                    AppUser *user = [APP_DELEGATE userWithName:newuser.username];
                    [user setDataWithEvercamUser:newuser];
                    [user setApiKeyPairWithApiKey:userKeyPair.apiKey andApiId:userKeyPair.apiId];
                    [APP_DELEGATE saveContext];
                    [APP_DELEGATE setDefaultUser:user];
                    
                    //Registering user with Intercom
                    [Intercom registerUserWithUserId:newuser.username];
                    
                    [GravatarServiceFactory requestUIImageByEmail:[APP_DELEGATE defaultUser].email defaultImage:gravatarServerImageMysteryMan size:72 delegate:self];
                    
                    if (isFromAddAccount) {
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
                    
                } else {
                    NSLog(@"Error %li: %@", (long)error.code, error.description);
                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [simpleAlert show];
                }
            }];
            
        }
        else
        {
            [_activityIndicator stopAnimating];
            NSLog(@"Error %li: %@", (long)error.code, error.description);
            
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log in", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [simpleAlert show];
        }
    }];
}

-(void)gravatarServiceDone:(id<GravatarService>)gravatarService
                 withImage:(UIImage *)image{
    NSLog(@"gravatarServiceDone");
    NSData *pngData = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[APP_DELEGATE defaultUser].email]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // if file is not exist, create it.
        
        [pngData writeToFile:filePath atomically:YES];
        
    }else{
        //overwrite file it already exist
        [pngData writeToFile:filePath atomically:YES];
    }
}

-(void)gravatarService:(id<GravatarService>)gravatarService
      didFailWithError:(NSError *)error{
    NSLog(@"gravatarService");
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onForgotPassword:(id)sender {
    ForgotPasswordViewController *fVc = [[ForgotPasswordViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ?@"ForgotPasswordViewController":@"ForgotPasswordViewController_iPad" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:fVc animated:YES];
}

- (IBAction)showPassAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    isPasswordHidden = !isPasswordHidden;
    
    if (isPasswordHidden) {
        if ([GlobalSettings sharedInstance].isPhone)
        {
            [btn setImage:[UIImage imageNamed:@"hidePass.png"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"hidePass.png"] forState:UIControlStateNormal];
        }

        
        self.txt_password.secureTextEntry = NO;
        
    }else{
        
        if ([GlobalSettings sharedInstance].isPhone)
        {
            [btn setImage:[UIImage imageNamed:@"showPassword.png"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"showPassword.png"] forState:UIControlStateNormal];
        }
        
        self.txt_password.secureTextEntry = YES;
    }
    
}

- (IBAction)onCreateAccount:(id)sender
{
    SignupViewController *vc    = [[SignupViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SignupViewController" : @"SignupViewController_iPad" bundle: [NSBundle mainBundle]];
    vc.isFromAddAccountScreen   = isFromAddAccount;
    NSMutableArray *vcArr       = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [vcArr removeLastObject];
    [vcArr addObject:vc];
    [self.navigationController setViewControllers:vcArr animated:YES];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txt_username)
    {
        [self.txt_password becomeFirstResponder];
    }
    else if (textField == self.txt_password)
    {
        [self.txt_password resignFirstResponder];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}

#pragma mark - UIKeyboard events
// Called when UIKeyboardWillShowNotification is sent
- (void)onKeyboardShow:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardFrameInWindow;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameInWindow];
    
    // the keyboard frame is specified in window-level coordinates. this calculates the frame as if it were a subview of our view, making it a sibling of the scroll view
    CGRect keyboardFrameInView = [self.view convertRect:keyboardFrameInWindow fromView:nil];
    
    CGRect scrollViewKeyboardIntersection = CGRectIntersection(_contentView.frame, keyboardFrameInView);
    UIEdgeInsets newContentInsets = UIEdgeInsetsMake(0, 0, scrollViewKeyboardIntersection.size.height, 0);
    
    // this is an old animation method, but the only one that retains compaitiblity between parameters (duration, curve) and the values contained in the userInfo-Dictionary.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    _contentView.contentInset = newContentInsets;
    _contentView.scrollIndicatorInsets = newContentInsets;
    
    /*
     * Depending on visual layout, _focusedControl should either be the input field (UITextField,..) or another element
     * that should be visible, e.g. a purchase button below an amount text field
     * it makes sense to set _focusedControl in delegates like -textFieldShouldBeginEditing: if you have multiple input fields
     */
    if (activeTextField) {
        CGRect controlFrameInScrollView = [_contentView convertRect:_btn_Signup.bounds fromView:_btn_Signup]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
        controlFrameInScrollView = CGRectInset(controlFrameInScrollView, 0, -10); // replace 10 with any nice visual offset between control and keyboard or control and top of the scroll view.
        
        CGFloat controlVisualOffsetToTopOfScrollview = controlFrameInScrollView.origin.y - _contentView.contentOffset.y;
        CGFloat controlVisualBottom = controlVisualOffsetToTopOfScrollview + controlFrameInScrollView.size.height;
        
        // this is the visible part of the scroll view that is not hidden by the keyboard
        CGFloat scrollViewVisibleHeight = _contentView.frame.size.height - scrollViewKeyboardIntersection.size.height;
        
        if (controlVisualBottom > scrollViewVisibleHeight) { // check if the keyboard will hide the control in question
            // scroll up until the control is in place
            CGPoint newContentOffset = _contentView.contentOffset;
            newContentOffset.y += (controlVisualBottom - scrollViewVisibleHeight);
            
            // make sure we don't set an impossible offset caused by the "nice visual offset"
            // if a control is at the bottom of the scroll view, it will end up just above the keyboard to eliminate scrolling inconsistencies
            newContentOffset.y = MIN(newContentOffset.y, _contentView.contentSize.height - scrollViewVisibleHeight);
            
            [_contentView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        } else if (controlFrameInScrollView.origin.y < _contentView.contentOffset.y) {
            // if the control is not fully visible, make it so (useful if the user taps on a partially visible input field
            CGPoint newContentOffset = _contentView.contentOffset;
            newContentOffset.y = controlFrameInScrollView.origin.y;
            
            [_contentView setContentOffset:newContentOffset animated:NO]; // animated:NO because we have created our own animation context around this code
        }
    }
    
    [UIView commitAnimations];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)onKeyboardHide:(NSNotification*)notification
{
    // if we have no view or are not visible in any window, we don't care
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    
    // undo all that keyboardWillShow-magic
    // the scroll view will adjust its contentOffset apropriately
    _contentView.contentInset = UIEdgeInsetsZero;
    _contentView.scrollIndicatorInsets = UIEdgeInsetsZero;
    
    [UIView commitAnimations];
}

#pragma mark - UITapGesture Recognizer
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [activeTextField resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101 || alertView.tag == 102) {
        [_txt_username becomeFirstResponder];
    }
    else if (alertView.tag == 103)
    {
        [_txt_password becomeFirstResponder];
    }
}

@end
