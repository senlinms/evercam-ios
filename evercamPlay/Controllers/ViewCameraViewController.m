//
//  AddCameraViewController.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "ViewCameraViewController.h"
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tvSnapshot flashScrollIndicators];
    [self.tvRTSPURL flashScrollIndicators];
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
    
    
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AddCameraViewController" : @"AddCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    addCameraVC.editCamera = self.camera;
    addCameraVC.delegate = self;
    [self.navigationController pushViewController:addCameraVC animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button Index: %ld",(long)buttonIndex);
    switch (buttonIndex) {
        case 0:{
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Camera"]) {
                [self edit:self];
            }else{
                [self deleteCamera];
            }
        }
            
            break;
        case 1:{
            [self deleteCamera];
        }
        default:
            break;
    }
}



- (IBAction)menu:(id)sender {       // to do put remove camera here
    
    if ([GlobalSettings sharedInstance].isPhone)
    {
    UIActionSheet *sheet;
    if ([self.camera.rights.rightsString rangeOfString:@"edit" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Camera",@"Remove Camera", nil];
        sheet.tag = 5608;
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Remove Camera", nil];
    }
    [sheet showInView:self.view];
    }else{
        //IPad
        [self presentActionSheetForIpad:sender];
    }
}

-(void)presentActionSheetForIpad:(id)sender{
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
    UIPopoverPresentationController *popPresenter = [view
                                                     popoverPresentationController];
    popPresenter.sourceView = (UIView *)sender;
    popPresenter.sourceRect = ((UIView *)sender).bounds;
    [self presentViewController:view animated:YES completion:nil];
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
    
    self.txtID.text             = self.camera.camId;
    self.lblName.text           = self.camera.name;
    self.lblOwner.text          = self.camera.owner;
    self.lblTimezone.text       = self.camera.timezone;
    
    [self setLabelValues:self.lblVendor withValue:self.camera.vendor];
    [self setLabelValues:self.lblModel withValue:self.camera.model];
    
    if ([self.camera.rights canEdit]) {
        
        [self.scrollView setContentSize:CGSizeMake(0, 625)];
        
        [self setLabelValues:self.lblUsername withValue:self.camera.username];
        [self setLabelValues:self.lblPassword withValue:self.camera.password];
        
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
        
        [self setLabelValues:self.lblExternalHost withValue:self.camera.externalHost];
        [self setLabelValues:self.lblInternalHost withValue:self.camera.internalHost];
        
        NSInteger externalHttpPort = self.camera.externalHttpPort;
        NSInteger externalRtspPort = self.camera.externalRtspPort;
        NSInteger internalHttpPort = self.camera.internalHttpPort;
        NSInteger internalRtspPort = self.camera.internalRtspPort;
        
        [self setPortLabels:self.lblExternalHTTPPort withValue:externalHttpPort];
        [self setPortLabels:self.lblExternalRTSPPort withValue:externalRtspPort];
        [self setPortLabels:self.lblInternalHTTPPort withValue:internalHttpPort];
        [self setPortLabels:self.lblInternalRTSPPort withValue:internalRtspPort];

    } else {
        
        for (UIView *viewToHide in self.editableParamsContainers) {
            viewToHide.hidden = YES;
        }
        
    }
}

-(void)setPortLabels:(UILabel *)label withValue:(NSInteger)value{
    if (value != 0) {
        label.text = [NSString stringWithFormat:@"%ld", (long)value];
    } else {
        label.text = @"Not specified";
        label.textColor = [UIColor lightGrayColor];
    }
}

-(void)setLabelValues:(UILabel *)label withValue:(NSString *)value{
    if ([self isValueNull:value]) {
        label.text = @"Not specified";
        label.textColor = [UIColor lightGrayColor];
    }else{
        if (value && value.length > 0) {
            label.text = value;
        } else {
            label.text = @"Not specified";
            label.textColor = [UIColor lightGrayColor];
        }
    }
}

-(BOOL)isValueNull:(NSString *)value{
    
    BOOL isNull = NO;
    
    if ([value isKindOfClass:[NSNull class]]) {
        isNull = YES;
    }
    
    return isNull;
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
