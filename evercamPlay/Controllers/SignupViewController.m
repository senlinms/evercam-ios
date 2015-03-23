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

@interface SignupViewController ()
{
    UITextField *activeTextField;
    NIDropDown *dropDown;
}

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _contentView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.contentView.layer insertSublayer:gradient atIndex:0];

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

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
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
    NSString *country = _btn_country.titleLabel.text;
    NSString *repassword = _txt_confirmPassword.text;
    NSString *countrycode = @"";
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    NSArray *countryArray = [NSLocale ISOCountryCodes];
    
    for (NSString *countryCode in countryArray)
    {
        NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
        if ([displayNameString isEqualToString:country])
        {
            countrycode = countryCode;
            break;
        }
    }
    
    // firstname
    if ([firstname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertController * alert= [UIAlertController
                                      alertControllerWithTitle:@"Firstname required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_firstname becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        user.firstname = firstname;
    }
    
    // lastname
    if ([lastname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Lastname required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_lastname becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        user.lastname = lastname;
    }

    // username
    if ([username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Username required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_username becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if ([username containsString:@" "])
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Invalid username"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_username becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (username.length < 3)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Username is too short"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_username becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        user.username = username;
    }
    // country
    user.country = countrycode;
    
    // email
    if ([email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length <= 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Email required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_email becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if ([self NSStringIsValidEmail:email] == NO)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Invalid email"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_email becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        user.email = email;
    }
    
    // Password 
    if (password.length <= 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Password required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_password becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if (repassword.length <= 0)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Confirm password required"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [_txt_confirmPassword becomeFirstResponder];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if ([password isEqualToString:repassword] == NO)
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Password not match"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else
    {
        user.password = password;
    }

    [_activityIndicator startAnimating];
    [[EvercamShell shell] createUser:user WithBlock:^(EvercamUser *newuser, NSError *error) {
        [_activityIndicator stopAnimating];
        if (error == nil)
        {
            if (newuser)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    LoginViewController *vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    NSMutableArray *vcArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                    [vcArr removeLastObject];
                    [vcArr addObject:vc];
                    [self.navigationController setViewControllers:vcArr animated:YES];
                });
            }
        }
        else
        {
            NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: @"Error"
                                              message:error.localizedDescription
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
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

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeTextField = nil;
}

#pragma mark - Keyboard Event Functions
- (void)keyboardWillHide:(NSNotification *)notif {
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    // Move view
    [_contentView setContentOffset:CGPointZero animated:YES];
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect endFrame = [[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[[notif userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    NSTimeInterval duration = [[[notif userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"resize" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:TRUE];
    
    if(([[UIDevice currentDevice].systemVersion floatValue] < 8) &&
       UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        int width = endFrame.size.height;
        endFrame.size.height = endFrame.size.width;
        endFrame.size.width = width;
    }
    
    CGRect frame = self.view.frame;
    frame.size.height -= endFrame.size.height;
    CGPoint fOrigin = activeTextField.frame.origin;
    fOrigin.y -= _contentView.contentOffset.y;
    fOrigin.y += _contentView.frame.origin.y;
    fOrigin.y += activeTextField.frame.size.height;
    if (!CGRectContainsPoint(frame, fOrigin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeTextField.frame.origin.y + activeTextField.frame.size.height - frame.size.height + _contentView.frame.origin.y);
        [_contentView setContentOffset:scrollPoint animated:YES];
    }
    
    [UIView commitAnimations];
}

#pragma mark NIDropdown delegate
- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    dropDown = nil;
}

@end
