//
//  CameraDetailViewController.m
//  evercamPlay
//
//  Created by Zulqarnain Mustafa on 2/7/17.
//  Copyright © 2017 evercom. All rights reserved.
//

#import "CameraDetailViewController.h"
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
#import "GlobalSettings.h"
#import "Config.h"
#import "BlockActionSheet.h"
#import "Appdelegate.h"
#import "CameraPlayViewController.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "LocationUpdateViewController.h"

@interface CameraDetailViewController ()<AddCameraViewControllerDelegate,LocationUpdateViewControllerDelegate>{
    
    NSMutableArray *modelsObjectArray;
    
}

@property (nonatomic, strong) EvercamVendor *currentVendor;
@property (nonatomic, strong) EvercamModel *currentModel;
@property (nonatomic, strong) NSMutableArray *vendorsArray;
@property (nonatomic, strong) NSMutableArray *vendorsNameArray;

@end

@implementation CameraDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self fillCameraDetails];
    [self getAllVendors];
    
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

- (void)viewDidLayoutSubviews{
//    [self.detail_ScrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 64)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)optionsButton:(id)sender {
    NSLog(@"Scroll: %@",NSStringFromCGRect(self.detail_ScrollView.frame));
    NSLog(@"ContentSize: %@",NSStringFromCGSize(self.detail_ScrollView.contentSize));
    
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
            [self goBack:nil];
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

- (IBAction)edit:(id)sender {
    
    AddCameraViewController *addCameraVC = [[AddCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"AddCameraViewController" : @"AddCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    addCameraVC.editCamera = self.camera;
    addCameraVC.delegate = self;
    [self.navigationController pushViewController:addCameraVC animated:YES];
}


- (void)fillCameraDetails {
    
    self.camera_Name_Label.text           = self.camera.name;
    [self.vendorButton setTitle:self.camera.vendor forState:UIControlStateNormal];
    [self.modelButton setTitle:self.camera.model forState:UIControlStateNormal];
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    
    point1.coordinate = CLLocationCoordinate2DMake(self.camera.latitude, self.camera.longitude);
    
    [self.camera_Map addAnnotation:point1];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.camera.latitude longitude:self.camera.longitude];
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        location.coordinate, 1000, 1000);
    [self.camera_Map setRegion:region animated:YES];
    
}


- (void)getAllVendors {
    
    self.view.userInteractionEnabled = NO;
    [self.vendorsNameArray removeAllObjects];
    [self.vendorsArray removeAllObjects];
    
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        if (!error) {
            self.vendorsArray  = [vendors mutableCopy];
            //            Sort evercamvendor object array by name
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            self.vendorsArray   = [[self.vendorsArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            
            self.vendorsNameArray    = [[vendors valueForKey:@"name"] mutableCopy];
            //Sort vendor name Array
            self.vendorsNameArray = [[self.vendorsNameArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            [self.vendorsNameArray insertObject:@"Unknown/Other" atIndex:0];
            self.view.userInteractionEnabled = YES;
            
            self.currentVendor = [self getVendorWithName:self.camera.vendor];
            if (![self.currentVendor.name isEqualToString:@"Other"]) {
                
                [self.camera_Vendor_ImageView sd_setImageWithURL:[NSURL URLWithString:self.currentVendor.logoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (self.currentVendor == nil) {
                        self.camera_Vendor_ImageView.image = nil;
                    }
                }];
                NSString *modelImageUrl    = [NSString stringWithFormat:@"https://evercam-public-assets.s3.amazonaws.com/%@/%@/thumbnail.jpg",self.currentVendor.vId,self.camera.model_id];
                [self.camera_Model_ImageView sd_setImageWithURL:[NSURL URLWithString:modelImageUrl] placeholderImage:[UIImage imageNamed:@"cam.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (self.currentVendor == nil) {
                        self.camera_Model_ImageView.image = [UIImage imageNamed:@"cam.png"];
                    }
                }];
//                [self getCameraModel:self.currentVendor.vId];
            }else{
                NSLog(@"CAMERA VENDOR AND MODEL UNKNOWN.");
            }
            
        }else{
            NSLog(@"VENDOR SERVICE ERROR: %@",error.description);
            
            self.view.userInteractionEnabled = YES;
        }
    }];
}


- (EvercamVendor *)getVendorWithName:(NSString *)vendorName {
    
    if ([vendorName isEqualToString:@"Unknown/Other"]) {
        return nil;
    }
    
    for (EvercamVendor *vendor in self.vendorsArray) {
        if ([vendor.name isEqualToString:vendorName]) {
            return vendor;
        }
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorRed;
//            pinView.image = [UIImage imageNamed:@"ic_link_iOS.png"];
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (IBAction)goUpdateLocation:(id)sender {
    
    LocationUpdateViewController *addCameraVC = [[LocationUpdateViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"LocationUpdateViewController" : @"LocationUpdateViewController" bundle:[NSBundle mainBundle]];
    addCameraVC.cameraToUpdate = self.camera;
    addCameraVC.delegate = self;
    [self.navigationController pushViewController:addCameraVC animated:YES];
}


#pragma mark - AddCameraViewController Delegate Method
- (void)cameraAdded:(EvercamCamera *)camera
{
    
}

- (void)cameraEdited:(EvercamCamera *)camera {
    [self goBack:nil];
    if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
        [self.delegate cameraEdited:camera];
    }
}



@end
