//
//  ShareSettingViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "ShareSettingViewController.h"
#import "EvercamUtility.h"
#import "AppDelegate.h"
#import "EvercamShare.h"
#import "ShareViewController.h"
@interface ShareSettingViewController (){
    NSArray *optionsArray;
    NSIndexPath *checkedIndexPath;
}

@end

@implementation ShareSettingViewController
@synthesize userDictionary;
@synthesize isUserRights,isPendingUser;
@synthesize rightsString,cameraId;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (isUserRights) {
        optionsArray            = [NSArray arrayWithObjects:@"Full Rights",@"Read Only",@"No Access", nil];
        rightsString            = [AppUtility getCameraRights:userDictionary[@"rights"]];
        self.resendBtn.hidden   = isPendingUser?NO:YES;
    }else{
        optionsArray = [NSArray arrayWithObjects:@"Public on the web",@"Anyone with the link",@"Only specific users", nil];
        self.resendBtn.hidden   = YES;
        self.navigationBar_Label.text = @"";
    }

    [optionsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == rightsString) {
            checkedIndexPath = [NSIndexPath indexPathForItem:idx inSection:0];
            [self.settingTableView reloadData];
        }
    }];
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save_Settings:(id)sender {
//     [self.loadingActivityIndicator startAnimating];
    if (isUserRights) {
        NSString *newRights = nil;
        if (checkedIndexPath.row == 0) {
            //Full Rights
            newRights = @"Snapshot,View,Edit,List";
            [self setCameraRightsForUser:newRights];
        }else if (checkedIndexPath.row == 1){
            //Read Only
            newRights = @"Snapshot,List";
            [self setCameraRightsForUser:newRights];
        }else{
            //No Access
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Are you sure you want to remove this share?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
            [alert show];
        }
    }else{
        NSString *choosenOption = optionsArray[checkedIndexPath.row];
        if ([choosenOption isEqualToString:@"Public on the web"]) {
            [self setCameraStatus_isDiscoverable:YES with_IsPublic:YES];
        }else if ([choosenOption isEqualToString:@"Anyone with the link"]){
            [self setCameraStatus_isDiscoverable:YES with_IsPublic:NO];
        }else{
            //Only specific users
            [self setCameraStatus_isDiscoverable:NO with_IsPublic:NO];
        }
    }
}

- (IBAction)resendShareRequest:(id)sender {
    [self.loadingActivityIndicator startAnimating];
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"camera_id"],@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSNumber numberWithBool:isPendingUser],@"isPending",[NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"email"],@"email", nil],@"Post_Param", nil];
    [EvercamShare New_Resend_CameraShare:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loadingActivityIndicator stopAnimating];
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"Success!" message:details[@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag           = 5606;
            [alert show];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            if (error.userInfo[@"Error_Server"]) {
                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.userInfo[@"Error_Server"]];
            }else{
                [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
            }
            
        }
    }];
}

-(void)setCameraStatus_isDiscoverable:(BOOL)isDiscoverable with_IsPublic:(BOOL)isPublic{
    [self.loadingActivityIndicator startAnimating];
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:cameraId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isPublic],@"is_public",[NSNumber numberWithBool:isDiscoverable],@"discoverable", nil],@"Post_Param", nil];
    [EvercamShare changeCameraStatus:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loadingActivityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(void)setCameraRightsForUser:(NSString *)newRights{
    [self.loadingActivityIndicator startAnimating];
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"camera_id"],@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSNumber numberWithBool:isPendingUser],@"isPending",[NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"email"],@"email",newRights,@"rights", nil],@"Post_Param", nil];
    
    [EvercamShare updateUserRights:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loadingActivityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(void)blockAccessOfUser{
    [self.loadingActivityIndicator startAnimating];
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"camera_id"],@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",userDictionary[@"email"],@"user_Email",[NSNumber numberWithBool:isPendingUser],@"isPending", nil];
    [EvercamShare deleteCameraShare:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loadingActivityIndicator stopAnimating];
            AppUser *user = [APP_DELEGATE defaultUser];
            if ([user.email isEqualToString:userDictionary[@"email"]]) {
                //back to live view
                AppUtility.isFullyDismiss  = YES;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 5606) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if (buttonIndex == 1) {
        [self blockAccessOfUser];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return optionsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = optionsArray[indexPath.row];
    if (checkedIndexPath.row == indexPath.row) {
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        checkedIndexPath    = indexPath;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppUser *user = [APP_DELEGATE defaultUser];
    if ([user.email isEqualToString:userDictionary[@"email"]] && isUserRights) {
        UITableViewCell* cellCheck = [tableView
                                      cellForRowAtIndexPath:indexPath];
        if (indexPath.row != 2 && ![cellCheck.textLabel.text isEqualToString:rightsString]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [AppUtility displayAlertWithTitle:@"Sorry!" AndMessage:@"You can not change your own rights."];
            return;
        }
    }
    
    if (indexPath != checkedIndexPath) {
        UITableViewCell* uncheckCell = [tableView
                                        cellForRowAtIndexPath:checkedIndexPath];
        uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell* cellCheck = [tableView
                                      cellForRowAtIndexPath:indexPath];
        cellCheck.accessoryType = UITableViewCellAccessoryCheckmark;
        checkedIndexPath = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
