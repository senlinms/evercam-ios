//
//  AddCameraViewController.h
//  EvercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamCamera.h"
#import "Intercom/intercom.h"

@class TPKeyboardAvoidingScrollView;
@protocol AddCameraViewControllerDelegate <NSObject>

- (void)cameraAdded:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface AddCameraViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *ipAddressView;
@property (weak, nonatomic) IBOutlet UIView *httpPortView;
@property (weak, nonatomic) IBOutlet UIView *rtspPortView;
@property (weak, nonatomic) IBOutlet UIView *credentialsView;
@property (weak, nonatomic) IBOutlet UIView *formView;
@property (weak, nonatomic) IBOutlet UITextField *tfID;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfVendor;
@property (weak, nonatomic) IBOutlet UITextField *tfModel;
@property (weak, nonatomic) IBOutlet UITextField *tfUsername;
@property (weak, nonatomic) IBOutlet UITextField *tfPassword;
@property (weak, nonatomic) IBOutlet UITextField *tfSnapshot;
@property (weak, nonatomic) IBOutlet UITextField *tfExternalHost;
@property (weak, nonatomic) IBOutlet UITextField *tfExternalHttpPort;
@property (weak, nonatomic) IBOutlet UITextField *tfExternalRtspPort;
@property (weak, nonatomic) IBOutlet UITextField *tfExternalRtspUrl;
@property (weak, nonatomic) IBOutlet UIButton *modelBtn;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *main_Scroll;
@property (weak, nonatomic) IBOutlet UIView *blackTransparentView;


@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (weak, nonatomic) IBOutlet UIView *testInsideView;

@property (nonatomic, strong) id<AddCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) EvercamCamera *editCamera;
@property (weak, nonatomic) IBOutlet UIButton *vendorBtn;

@property (weak, nonatomic) IBOutlet UIView *success_Message_View;
@property (weak, nonatomic) IBOutlet UIImageView *test_SnapShot_ImageView;
- (IBAction)remove_Message_View:(id)sender;
- (IBAction)questionMarkAction:(id)sender;
- (IBAction)open_LiveSupport:(id)sender;

@end
