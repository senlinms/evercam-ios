//
//  AddAccountView.m
//  EvercamPlay
//
//  Created by menghu on 5/25/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "GlobalSettings.h"
#import "AddAccountView.h"

@interface AddAccountView ()

@property (nonatomic, weak) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIView *grayView;
@property (nonatomic, weak) IBOutlet UIView *editView;

@end

@implementation AddAccountView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.grayView.frame = frame;
        _editView.layer.cornerRadius = 4.0;
        _editView.layer.masksToBounds = YES;
        
        if ([self.usernameField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            UIColor *color = [UIColor lightTextColor];
            self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email/Username" attributes:@{NSForegroundColorAttributeName: color}];
            self.passwdField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
        } else {
            NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");

        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:) name:UIKeyboardDidShowNotification object:nil];
    }
    return self;
}

-(void)reframeSubView:(CGPoint)center andFrame:(CGRect)frame
{
    self.editView.center = center;
    self.grayView.frame = frame;
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:[GlobalSettings sharedInstance].isPhone ? @"AddAccountView" : @"AddAccountView_iPad" owner:self options:nil];
        
    [self addSubview:self.view];
}

- (IBAction)onCancel:(id)sender
{
    NSLog(@"%f", self.view.frame.size.width);
    [self.delegate clickedOnCancel];
}

- (IBAction)onAdd:(id)sender
{
    [self.delegate clickedonAddWithName:_usernameField.text withPassword:_passwdField.text];
    [self.usernameField resignFirstResponder];
    [self.passwdField resignFirstResponder];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField)
    {
        [self.passwdField becomeFirstResponder];
    }
    else if (textField == self.passwdField)
    {
        [self.passwdField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - keyboard notification
- (void)keyboardDidShown:(NSNotification*)notification
{
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    
//    [UIView animateWithDuration:0.2f
//                          delay:0.0f
//                        options: UIViewAnimationOptionAllowUserInteraction
//                     animations: ^{
//                         [self.editView setFrame:CGRectMake(self.editView.frame.origin.x,
//                                                            self.view.frame.size.height - keyboardSize.height - self.editView.frame.size.height - 10,
//                                                            self.editView.frame.size.width,
//                                                            self.editView.frame.size.height)];
//                     }
//                     completion: ^(BOOL finished) {
//                         
//                     }
//     ];
}


@end

