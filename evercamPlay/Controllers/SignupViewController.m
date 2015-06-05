//
//  SignupViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
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
#import "GAIDictionaryBuilder.h"
#import "Config.h"
#import "GlobalSettings.h"
#import "Mixpanel.h"

@interface SignupViewController ()
{
    UITextField *activeTextField;
    NIDropDown *dropDown;
}

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Create Account";
    
    // Do any additional setup after loading the view from its nib.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    [self.contentView setContentSize:CGSizeMake(0, 300)];

    if ([self.txt_username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightTextColor];
        self.txt_firstname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First name" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_lastname.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last name" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_confirmPassword.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
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

#pragma mark Validation 
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark UI Action
- (IBAction)onCountry:(id)sender
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    NSMutableArray *sortedCountryArray = [[NSMutableArray alloc] init];

    for (NSString *countryCode in countryArray)
    {
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        [sortedCountryArray addObject:displayNameString];
    }
    
    [sortedCountryArray sortUsingSelector:@selector(compare:)];
    NSArray * arrImage = [[NSArray alloc] init];

    if(dropDown == nil) {
        CGFloat f = 200;
        dropDown = [[NIDropDown alloc] showDropDown:sender height:&f textArray:sortedCountryArray imageArray:arrImage direction:@"down"] ;
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }

}

- (IBAction)onCreateAccount:(id)sender
{
    EvercamUser *user = [EvercamUser new];
    NSString *firstname = _txt_firstname.text;
    NSString *lastname = _txt_lastname.text;
    NSString *email = _txt_email.text;
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;
    NSString *repassword = _txt_confirmPassword.text;
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLog(@"countryCode:%@", countryCode);
    
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
    else if ([username containsString:@" "])
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
    // country
    user.country = countryCode;
    
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
    if (password.length <= 0)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sign up", nil) message:NSLocalizedString(@"Password required", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        simpleAlert.tag = 108;
        [simpleAlert show];
        
        return;
    }
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
                                    
                                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                    
                                    [mixpanel track:mixpanel_event_sign_up properties:@{
                                                                                        @"username": newuser.username
                                                                                        }];
                                    
                                    AppUser *user = [APP_DELEGATE userWithName:newuser.username];
                                    [user setDataWithEvercamUser:newuser];
                                    [user setApiKeyPairWithApiKey:userKeyPair.apiKey andApiId:userKeyPair.apiId];
                                    [APP_DELEGATE saveContext];
                                    [APP_DELEGATE setDefaultUser:user];
                                    
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
                                    
                                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_sign_up
                                                                                          action:action_signup_success
                                                                                           label:label_signup_successful
                                                                                           value:nil] build]];
                                    
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
        CGRect controlFrameInScrollView = [_contentView convertRect:activeTextField.bounds fromView:activeTextField]; // if the control is a deep in the hierarchy below the scroll view, this will calculate the frame as if it were a direct subview
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

#pragma mark NIDropdown delegate
- (void) niDropDown:(NIDropDown*)dropdown didSelectAtIndex:(NSInteger)index
{
    dropDown = nil;
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
