//
//  CameraNameViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/13/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "CameraNameViewController.h"
#import "EvercamUtility.h"
#import "MBProgressHUD.h"
#import "EvercamCreateCamera.h"
#import "AppDelegate.h"
#import "Config.h"
#import "GAIDictionaryBuilder.h"
@import Firebase;
@interface CameraNameViewController ()

@end

@implementation CameraNameViewController
@synthesize postDictionary;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)doneAction:(id)sender {
    
    if (isCompletelyEmpty(self.nametextField.text)) {
        [AppUtility displayAlertWithTitle:@"Alert!" AndMessage:@"Please enter a valid camera name."];
        return;
    }
    [self.nametextField resignFirstResponder];
    
    [postDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.nametextField.text,@"name", nil]];
    
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",postDictionary,@"Post_Param", nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EvercamCreateCamera *api_create_Obj = [EvercamCreateCamera new];
    [api_create_Obj createCamera:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            
            [FIRAnalytics logEventWithName:@"Add_Camera"
                                parameters:@{
                                             @"Camera_Addition_Status": @"Successfully added new camera."
                                             }];

            [MBProgressHUD hideHUDForView:self.view animated:YES];
            AppUtility.isFullyDismiss = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
             [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.localizedDescription];
        }
    }];
    
    
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
