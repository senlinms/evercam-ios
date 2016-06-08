//
//  VendorAndModelViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/8/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "VendorAndModelViewController.h"
#import "EvercamCamera.h"
#import "EvercamShell.h"
#import "EvercamVendor.h"
#import "EvercamModel.h"
#import "ActionSheetPicker.h"
#import "UIImageView+WebCache.h"
@interface VendorAndModelViewController (){
    NSMutableArray *vendorsNameArray;
    NSMutableArray *vendorsObjectArray;
    NSMutableArray *modelsObjectArray;
    
}

@end

@implementation VendorAndModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getAllVendors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            vendorsNameArray    = [[vendors valueForKey:@"name"] mutableCopy];
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
            NSArray *filteredArray = [modelsObjectArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",@"Default"]];
            EvercamModel *cameraModel = filteredArray[0];
            [self.modelBtn setTitle:cameraModel.name forState:UIControlStateNormal];
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
            if ([selectedValue isEqualToString:@"Unknown/Other"]) {
                self.cameraImage.image      = [UIImage imageNamed:@"cam.png"];
                self.vendorImageView.image  = nil;
                self.modelBtn.enabled       = NO;
            }else{
                EvercamVendor *cameraVendor = vendorsObjectArray[selectedIndex-1];
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
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:sender];
    }
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
