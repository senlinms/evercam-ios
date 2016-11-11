//
//  VendorAndModelViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/8/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "VendorAndModelViewController.h"
#import "ReportCameraViewController.h"
#import "ConnectCameraViewController.h"
#import "EvercamCamera.h"
#import "EvercamShell.h"
#import "EvercamVendor.h"
#import "EvercamModel.h"
#import "ActionSheetPicker.h"
#import "UIImageView+WebCache.h"
#import "EvercamUtility.h"
#import "GlobalSettings.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UnknownConnectCameraViewController.h"
@interface VendorAndModelViewController (){
    NSMutableArray *vendorsNameArray;
    NSMutableArray *vendorsObjectArray;
    NSMutableArray *modelsObjectArray;
    EvercamModel *cameraModel;
    EvercamVendor *cameraVendor;
    
}

@end

@implementation VendorAndModelViewController
@synthesize vendorIdentifier;
@synthesize scanned_Device;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getAllVendors];
    [self.contentScrollView contentSizeToFit];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (AppUtility.isFullyDismiss) {
        AppUtility.isFullyDismiss = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.contentScrollView contentSizeToFit];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getAllVendors {
    [self.loading_ActivityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    [vendorsNameArray removeAllObjects];
    [vendorsObjectArray removeAllObjects];
    
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        if (!error) {
            vendorsObjectArray  = [vendors mutableCopy];
            //Sort evercamvendor object array by name
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            vendorsObjectArray=[[vendorsObjectArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            
            if (vendorIdentifier) {
                NSArray *filteredArray = [vendorsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(vId == %@)",vendorIdentifier]];
                if (filteredArray.count > 0) {
                    cameraVendor = filteredArray[0];
                    [self getCameraModel:cameraVendor.vId];
                    [self.vendorImageView sd_setImageWithURL:[NSURL URLWithString:cameraVendor.logoUrl] placeholderImage:[UIImage imageNamed:@""]];
                    [self.vendorBtn setTitle:cameraVendor.name forState:UIControlStateNormal];
                }
            }
            
            vendorsNameArray    = [[vendors valueForKey:@"name"] mutableCopy];
            //Sort vendor name Array
            vendorsNameArray = [[vendorsNameArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] mutableCopy];
            [vendorsNameArray insertObject:@"Unknown/Other" atIndex:0];
            [self.loading_ActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
        }else{
            NSLog(@"VENDOR SERVICE ERROR: %@",error.description);
            [self.loading_ActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
        }
    }];
}

-(void)getCameraModel:(NSString *)vendorId{
    [modelsObjectArray removeAllObjects];
    [[EvercamShell shell] getAllModelsByVendorId:vendorId withBlock:^(NSArray *models, NSError *error) {
        if (!error) {
            modelsObjectArray = [models mutableCopy];
            //Sort evercammodel object array by name
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            modelsObjectArray=[[modelsObjectArray sortedArrayUsingDescriptors:@[sort]] mutableCopy];
            if (vendorIdentifier) {
                NSArray *filteredArray = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",scanned_Device.onvif_Camera_model]];
                if (filteredArray.count > 0) {
                    cameraModel = filteredArray[0];
                }else{
                    //In case Evercam have not record of this model in it's database
                    NSArray *filteredArray = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",@"Default"]];
                    cameraModel = filteredArray[0];
                    [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Evercam does not have this camera model in it's record. Please report this model."];
                }
            }else{
                NSArray *filteredArray = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",@"Default"]];
                cameraModel = filteredArray[0];
            }
            self.modelBtn.enabled = FALSE;
            [self.modelBtn setTitle:cameraModel.name forState:UIControlStateNormal];
            [self.modelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.modelBtn.enabled = TRUE;
            [self.cameraImage sd_setImageWithURL:[NSURL URLWithString:cameraModel.thumbUrl] placeholderImage:[UIImage imageNamed:@"cam.png"]];
            [self.loading_ActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
        }else{
            [self.loading_ActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
        }
    }];

}

- (IBAction)vendorAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (vendorsNameArray.count > 0) {
        
        [ActionSheetStringPicker showPickerWithTitle:@"Vendors" rows:vendorsNameArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
            [btn setTitle:selectedValue forState:UIControlStateNormal];
            if ([selectedValue isEqualToString:@"Unknown/Other"] || [selectedValue isEqualToString:@"Other"]) {
                self.cameraImage.image      = [UIImage imageNamed:@"cam.png"];
                self.vendorImageView.image  = nil;
                self.modelBtn.enabled       = NO;
                [self.modelBtn setTitle:@"Unknown/Other" forState:UIControlStateNormal];
                [self.modelBtn setTitleColor:[AppUtility colorWithHexString:@"B9B9B9"] forState:UIControlStateNormal];
            }else{
                cameraVendor = vendorsObjectArray[selectedIndex-1];
                [self.loading_ActivityIndicator startAnimating];
                self.view.userInteractionEnabled = NO;
                [self getCameraModel:cameraVendor.vId];
                [self.vendorImageView sd_setImageWithURL:[NSURL URLWithString:cameraVendor.logoUrl] placeholderImage:[UIImage imageNamed:@""]];
            }
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:sender];
        
    }
}

- (IBAction)modelAction:(id)sender {
    if (modelsObjectArray.count > 0) {
        [ActionSheetStringPicker showPickerWithTitle:@"Models" rows:[modelsObjectArray valueForKey:@"name"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            cameraModel = modelsObjectArray[selectedIndex];
            self.modelBtn.enabled = FALSE;
            [self.modelBtn setTitle:cameraModel.name forState:UIControlStateNormal];
            [self.modelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.modelBtn.enabled = TRUE;
            [self.cameraImage sd_setImageWithURL:[NSURL URLWithString:cameraModel.thumbUrl] placeholderImage:[UIImage imageNamed:@"cam.png"]];
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:sender];
    }
}

- (IBAction)backAction:(id)sender {
    AppUtility.isFromScannedScreen = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reportModel:(id)sender {
    ReportCameraViewController *aVC = [[ReportCameraViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ReportCameraViewController":@"ReportCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    if (![GlobalSettings sharedInstance].isPhone) {
        aVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    ([GlobalSettings sharedInstance].isPhone)? [self.navigationController pushViewController:aVC animated:YES]:[self presentViewController:aVC animated:YES completion:NULL];
}

- (IBAction)connectCamera:(id)sender {
    if ([self.vendorBtn.titleLabel.text isEqualToString:@"Unknown/Other"] || [self.vendorBtn.titleLabel.text isEqualToString:@"Other"]) {
        UnknownConnectCameraViewController *aVC = [[UnknownConnectCameraViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"UnknownConnectCameraViewController":@"UnknownConnectCameraViewController_iPad" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:aVC animated:YES];
    }else{
        ConnectCameraViewController *aVC = [[ConnectCameraViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ConnectCameraViewController":@"ConnectCameraViewController_iPad" bundle:[NSBundle mainBundle]];
        aVC.selected_cameraModel    = cameraModel;
        aVC.selected_cameraVendor   = cameraVendor;
        if (vendorIdentifier) {
            aVC.camera_Http_Port    = scanned_Device.http_Port;
        }
        [self.navigationController pushViewController:aVC animated:YES];
    }

}
@end
