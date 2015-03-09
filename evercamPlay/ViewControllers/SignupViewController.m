//
//  SignupViewController.m
//  evercamPlay
//
//  Created by jw on 3/8/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()
{
    UITextField *activeTextField;
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
        self.txt_country.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Please select" attributes:@{NSForegroundColorAttributeName: color}];
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

- (IBAction)onCreateAccount:(id)sender
{
    
    
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
        [self.txt_country becomeFirstResponder];
    }
    else if (textField == self.txt_country)
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

@end
