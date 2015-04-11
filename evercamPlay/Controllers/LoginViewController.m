//
//  LoginViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
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

@interface LoginViewController ()
{
    UITextField *activeTextField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _contentView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.contentView.layer insertSublayer:gradient atIndex:0];
    
    if ([self.txt_username respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor lightTextColor];
        self.txt_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email/Username" attributes:@{NSForegroundColorAttributeName: color}];
        self.txt_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
        // TODO: Add fall-back code to set placeholder color.
    }
    
    self.txt_password.text = @"marcopolo";
    self.txt_username.text = @"marco";
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

- (IBAction)onLogin:(id)sender
{
    NSString *username = _txt_username.text;
    NSString *password = _txt_password.text;
    
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
    else if (password.length <= 0)
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
    

    [_activityIndicator startAnimating];
    [[EvercamShell shell] requestEvercamAPIKeyFromEvercamUser:username Password:password WithBlock:^(EvercamApiKeyPair *userKeyPair, NSError *error) {
        if (error == nil)
        {
            [[EvercamShell shell] getUserFromId:username withBlock:^(EvercamUser *newuser, NSError *error) {
                [_activityIndicator stopAnimating];
                if (error == nil) {
                    AppUser *user = [APP_DELEGATE userWithName:newuser.username];
                    [user setDataWithEvercamUser:newuser];
                    [user setApiKeyPairWithApiKey:userKeyPair.apiKey andApiId:userKeyPair.apiId];
                    [APP_DELEGATE saveContext];
                    [APP_DELEGATE setDefaultUser:user];
                    
                    CamerasViewController *camerasViewController = [[CamerasViewController alloc] init];
                    MenuViewController *menuViewController = [[MenuViewController alloc] init];
                    
                    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:camerasViewController];
                    frontNavigationController.navigationBarHidden = YES;
                    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:menuViewController];
                    rearNavigationController.navigationBarHidden = YES;
                    
                    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
                    [self.navigationController pushViewController:revealController animated:YES];

                } else {
                    NSLog(@"Error %li: %@", (long)error.code, error.description);
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
                }
            }];
            
        }
        else
        {
            [_activityIndicator stopAnimating];
            NSLog(@"Error %li: %@", (long)error.code, error.description);
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
        }
    }];
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCreateAccount:(id)sender
{
    SignupViewController *vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    NSMutableArray *vcArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
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
    activeTextField = self.txt_password;
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

@end
