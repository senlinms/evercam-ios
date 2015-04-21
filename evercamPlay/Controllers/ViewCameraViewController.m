//
//  AddCameraViewController.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "ViewCameraViewController.H"
#import "SelectVendorViewController.h"
#import "SelectModelViewController.h"
#import "AddCameraViewController.h"
#import "EvercamVendor.h"
#import "EvercamModel.h"
#import "EvercamCameraBuilder.h"
#import "EvercamCamera.h"
#import "EvercamShell.h"
#import "MBProgressHUD.h"
#import "CommonUtil.h"

@interface ViewCameraViewController () <AddCameraViewControllerDelegate>

@property (strong, nonatomic) UITextField *focusedTextField;

@end

@implementation ViewCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"View Camera Detail";
    
    [self fillCameraDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:@"AddCameraViewController" bundle:nil];
    addCameraVC.editCamera = self.camera;
    addCameraVC.delegate = self;
    [self.navigationController pushViewController:addCameraVC animated:YES];
}

- (void)fillCameraDetails {
    self.lblID.text = self.camera.camId;
    self.lblName.text = self.camera.name;
    self.lblOwner.text = self.camera.owner;
    self.lblTimezone.text = self.camera.timezone;
    if (self.camera.vendor && self.camera.vendor.length > 0) {
        self.lblVendor.text = self.camera.vendor;
    } else {
        self.lblVendor.text = @"Not specified";
        self.lblVendor.textColor = [UIColor lightGrayColor];
    }
    if (self.camera.model && self.camera.model.length > 0) {
        self.lblModel.text = self.camera.model;
    } else {
        self.lblModel.text = @"Not specified";
        self.lblModel.textColor = [UIColor lightGrayColor];
    }
    
    if ([self.camera.rights canEdit]) {
        [self.scrollView setContentSize:CGSizeMake(0, 625)];
        
        if (self.camera.username && self.camera.username.length > 0) {
            self.lblUsername.text = self.camera.username;
        } else {
            self.lblUsername.text = @"Not specified";
            self.lblUsername.textColor = [UIColor lightGrayColor];
        }
        
        if (self.camera.password && self.camera.password.length > 0) {
            self.lblPassword.text = self.camera.password;
        } else {
            self.lblPassword.text = @"Not specified";
            self.lblPassword.textColor = [UIColor lightGrayColor];
        }
        
        NSString *jpgPath = [self.camera getJpgPath];
        if (jpgPath && jpgPath.length > 0) {
            self.tvSnapshot.text = jpgPath;
        } else {
            self.tvSnapshot.text = @"Not specified";
            self.tvSnapshot.textColor = [UIColor lightGrayColor];
        }
        
        if (self.camera.externalHost && self.camera.externalHost.length > 0) {
            self.lblExternalHost.text = self.camera.externalHost;
        } else {
            self.lblExternalHost.text = @"Not specified";
            self.lblExternalHost.textColor = [UIColor lightGrayColor];
        }
        
        if (self.camera.internalHost && self.camera.internalHost.length > 0) {
            self.lblInternalHost.text = self.camera.internalHost;
        } else {
            self.lblInternalHost.text = @"Not specified";
            self.lblInternalHost.textColor = [UIColor lightGrayColor];
        }
        
        NSInteger externalHttpPort = self.camera.externalHttpPort;
        NSInteger externalRtspPort = self.camera.externalRtspPort;
        NSInteger internalHttpPort = self.camera.internalHttpPort;
        NSInteger internalRtspPort = self.camera.internalRtspPort;
        
        if (externalHttpPort != 0) {
            self.lblExternalHTTPPort.text = [NSString stringWithFormat:@"%d", externalHttpPort];
        } else {
            self.lblExternalHTTPPort.text = @"Not specified";
            self.lblExternalHTTPPort.textColor = [UIColor lightGrayColor];
        }
        if (externalRtspPort != 0) {
            self.lblExternalRTSPPort.text = [NSString stringWithFormat:@"%d", externalRtspPort];
        } else {
            self.lblExternalRTSPPort.text = @"Not specified";
            self.lblExternalRTSPPort.textColor = [UIColor lightGrayColor];
        }
        if (internalHttpPort != 0) {
            self.lblInternalHTTPPort.text = [NSString stringWithFormat:@"%d", internalHttpPort];
        } else {
            self.lblInternalHTTPPort.text = @"Not specified";
            self.lblInternalHTTPPort.textColor = [UIColor lightGrayColor];
        }
        if (internalRtspPort != 0) {
            self.lblInternalRTSPPort.text = [NSString stringWithFormat:@"%d", internalRtspPort];
        } else {
            self.lblInternalRTSPPort.text = @"Not specified";
            self.lblInternalRTSPPort.textColor = [UIColor lightGrayColor];
        }
        
    } else {
        self.editContainerView.hidden = YES;
    }
}

#pragma mark - AddCameraViewController Delegate Method
- (void)cameraAdded:(EvercamCamera *)camera
{
    
}

- (void)cameraEdited:(EvercamCamera *)camera {
    [self back:nil];
    if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
        [self.delegate cameraEdited:camera];
    }
}

@end
