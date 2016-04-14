//
//  AddCameraViewController.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
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
#import "GAIDictionaryBuilder.h"
#import "GlobalSettings.h"
#import "Config.h"
#import "BlockActionSheet.h"
#import "Appdelegate.h"
#import "CameraPlayViewController.h"

@interface ViewCameraViewController () <AddCameraViewControllerDelegate>

@property (strong, nonatomic) UITextField *focusedTextField;

@end

@implementation ViewCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"View Camera Detail";
    
    [self fillCameraDetails];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)edit:(id)sender {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category_add_camera
                                                          action:category_add_camera
                                                           label:label_add_camera_manually
                                                           value:nil] build]];

    
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AddCameraViewController" : @"AddCameraViewController_iPad" bundle:nil];
    addCameraVC.editCamera = self.camera;
    addCameraVC.delegate = self;
    [self.navigationController pushViewController:addCameraVC animated:YES];
}

- (IBAction)menu:(id)sender {       // to do put remove camera here
 
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
            
            EvercamRights *right = self.camera.rights;
            if (right.rightsString) {

                if (([right.rightsString rangeOfString:@"edit"].location != NSNotFound) || ([right.rightsString rangeOfString:@"EDIT"].location != NSNotFound)) {
                    [sheet addButtonWithTitle:@"Edit Camera" block:^{
                        [self edit:self];
                    }];
                }
            }
            
            [sheet addButtonWithTitle:@"Remove Camera" block:^{
                [self deleteCamera];
            }];
            [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
            [sheet showInView:self.view];
        }
        else
        {
            UIAlertController * view=   [UIAlertController
                                         alertControllerWithTitle:nil
                                         message:nil
                                         preferredStyle:UIAlertControllerStyleActionSheet];
            
           
            UIAlertAction* editCamera = [UIAlertAction
                                          actionWithTitle:@"Edit Camera"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                                          {
                                              [view dismissViewControllerAnimated:YES completion:nil];
                                              [self edit:self];
                                              
                                          }];
           
            UIAlertAction* removeCamera = [UIAlertAction
                                           actionWithTitle:@"Remove Camera"
                                           style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction * action)
                                           {
                                               [view dismissViewControllerAnimated:YES completion:nil];
                                               [self deleteCamera];
                                               
                                           }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleCancel
                                     handler:^(UIAlertAction * action)
                                     {
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                     }];
            EvercamRights *right = self.camera.rights;
            if (right.rightsString) {
                if ([right.rightsString containsString:@"edit"] || [right.rightsString containsString:@"EDIT"]) {
                    [view addAction:editCamera];
                }
            }
    
            [view addAction:removeCamera];
            [view addAction:cancel];
            
            if ([GlobalSettings sharedInstance].isPhone)
            {
                [self presentViewController:view animated:YES completion:nil];
            }
            else
            {
                UIPopoverPresentationController *popPresenter = [view
                                                                 popoverPresentationController];
                popPresenter.sourceView = (UIView *)sender;
                popPresenter.sourceRect = ((UIView *)sender).bounds;
                [self presentViewController:view animated:YES completion:nil];
            }
        }
    }

- (void)deleteCamera {
    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove Camera", nil) message:NSLocalizedString(@"Are you sure you want to remove this camera?", nil) delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
    simpleAlert.tag = 102;
    [simpleAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 103) {
        [self.navigationController popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(cameraDeletedSettings:)]) {
            [self.delegate cameraDeletedSettings:self.camera];
        }
    }
    else if (alertView.tag == 101) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            CameraPlayViewController *vc = (CameraPlayViewController *)((CustomNavigationController *)self.presentingViewController).viewControllers[0];
            vc.isCameraRemoved = YES;
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self back:nil];
            if ([self.delegate respondsToSelector:@selector(cameraDeletedSettings:)]) {
                [self.delegate cameraDeletedSettings:self.camera];
            }
        }
    }
    else if(alertView.tag == 102 && buttonIndex == 1)
    {
        if ([self.camera.rights canDelete]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[EvercamShell shell] deleteCamera:self.camera.camId withBlock:^(BOOL success, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove camera", nil) message:NSLocalizedString(@"Camera deleted", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    simpleAlert.tag = 101;
                    [simpleAlert show];
                } else {
                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove camera", nil) message:@"Failed to delete camera, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [simpleAlert show];
                    
                    return;
                }
            }];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[EvercamShell shell] deleteShareCamera:self.camera.camId andUserEmail:[APP_DELEGATE defaultUser].email withBlock:^(BOOL success, NSError *error) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if (success) {
                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove camera", nil) message:NSLocalizedString(@"Camera deleted", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    simpleAlert.tag = 101;
                    [simpleAlert show];
                } else {
                    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remove camera", nil) message:@"Failed to delete camera, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [simpleAlert show];
                    
                    return;
                }
            }];
        }
    }
}
    


- (void)fillCameraDetails {
    self.txtID.text = self.camera.camId;
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
        
        if (![self.camera.password isKindOfClass:[NSNull class]])
        {
            if (self.camera.password.length > 0)
            {
                self.lblPassword.text = self.camera.password;
            }
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
        
        if (self.camera.externalH264Url && self.camera.externalH264Url.length > 0) {
            self.tvRTSPURL.text = [self.camera getRTSPUrl];
        } else {
            self.tvRTSPURL.text = @"Not specified";
            self.tvRTSPURL.textColor = [UIColor lightGrayColor];
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
            self.lblExternalHTTPPort.text = [NSString stringWithFormat:@"%ld", (long)externalHttpPort];
        } else {
            self.lblExternalHTTPPort.text = @"Not specified";
            self.lblExternalHTTPPort.textColor = [UIColor lightGrayColor];
        }
        if (externalRtspPort != 0) {
            self.lblExternalRTSPPort.text = [NSString stringWithFormat:@"%ld", (long)externalRtspPort];
        } else {
            self.lblExternalRTSPPort.text = @"Not specified";
            self.lblExternalRTSPPort.textColor = [UIColor lightGrayColor];
        }
        if (internalHttpPort != 0) {
            self.lblInternalHTTPPort.text = [NSString stringWithFormat:@"%ld", (long)internalHttpPort];
        } else {
            self.lblInternalHTTPPort.text = @"Not specified";
            self.lblInternalHTTPPort.textColor = [UIColor lightGrayColor];
        }
        if (internalRtspPort != 0) {
            self.lblInternalRTSPPort.text = [NSString stringWithFormat:@"%ld", (long)internalRtspPort];
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
