//
//  AddAccountView.h
//  evercamPlay
//
//  Created by menghu on 5/25/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddAccountViewDelegate;

@interface AddAccountView : UIView

@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwdField;

@property (nonatomic, strong) id<AddAccountViewDelegate> delegate;
-(void)reframeSubView:(CGPoint)center;
@end

@protocol AddAccountViewDelegate <NSObject>

@optional
- (void) clickedOnCancel;
- (void) clickedonAddWithName:(NSString *)username withPassword:(NSString *)password;

@end