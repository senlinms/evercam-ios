//
//  UnknownConnectCameraViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/16/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TPKeyboardAvoidingScrollView;
@interface UnknownConnectCameraViewController : UIViewController{
    
}

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *textField_scrollView;
@property (weak, nonatomic) IBOutlet UILabel *vendorLabel;
@property (weak, nonatomic) IBOutlet UITextField *ipAddress_textField;
@property (weak, nonatomic) IBOutlet UITextField *rtsp_TextField;
@property (weak, nonatomic) IBOutlet UITextField *http_TextField;
@property (weak, nonatomic) IBOutlet UILabel *httpPortLabel;
@property (weak, nonatomic) IBOutlet UILabel *rtspPortLabel;
@property (weak, nonatomic) IBOutlet UIView *authenticationView;
@property (weak, nonatomic) IBOutlet UIButton *snapShotBtn;
@property (weak, nonatomic) IBOutlet UIButton *liveSupportBtn;
@property (weak, nonatomic) IBOutlet UISwitch *authenticationSwitch;
@property (weak, nonatomic) IBOutlet UITextField *username_TextField;
@property (weak, nonatomic) IBOutlet UITextField *password_TextField;
@property (weak, nonatomic) IBOutlet UIView *blackTransparentView;
@property (weak, nonatomic) IBOutlet UIView *snapShotView;
@property (weak, nonatomic) IBOutlet UIImageView *snapShotImageView;
- (IBAction)nextStepBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *textFieldGuideLabel;
@property (weak, nonatomic) IBOutlet UITextField *snapshotPathTextField;
@property (weak, nonatomic) IBOutlet UITextField *rtspPathTextField;

- (IBAction)checkSnapShot:(id)sender;
- (IBAction)liveSupport:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)requireAuthenticationAction:(id)sender;
- (IBAction)blackTransparentViewTapped:(id)sender;

- (IBAction)textFieldsTextChanged:(id)sender;

@end
