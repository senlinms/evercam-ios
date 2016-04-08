//
//  AddCameraViewController.h
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamCamera.h"
#import "GAI.h"
#import "NIDropDown.h"

@protocol AddCameraViewControllerDelegate <NSObject>

- (void)cameraAdded:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface AddCameraViewController : GAITrackedViewController <NIDropDownDelegate,UIAlertViewDelegate>

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
@property (weak, nonatomic) IBOutlet UITextField *tfInternalHost;
@property (weak, nonatomic) IBOutlet UITextField *tfInternalHttpPort;
@property (weak, nonatomic) IBOutlet UITextField *tfInternalRtspPort;
@property (weak, nonatomic) IBOutlet UITextField *tfExternalRtspUrl;


@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@property (weak, nonatomic) IBOutlet UIView *testInsideView;

@property (nonatomic, strong) id<AddCameraViewControllerDelegate> delegate;
@property (nonatomic, strong) EvercamCamera *editCamera;

@end

static inline BOOL isCompletelyEmpty (id text) {
    BOOL isBlank;
    if ([[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        isBlank = YES;
    }else{
        isBlank = NO;
    }
    
    return isBlank;
}

