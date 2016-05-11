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
@interface ShareSettingViewController (){
    NSArray *optionsArray;
    NSString *rightsString;
    NSIndexPath *checkedIndexPath;
}

@end

@implementation ShareSettingViewController
@synthesize userDictionary;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    optionsArray = [NSArray arrayWithObjects:@"Full Rights",@"Read Only",@"No Access", nil];
    rightsString = [AppUtility getCameraRights:userDictionary[@"rights"]];
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
     [self.loadingActivityIndicator startAnimating];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

-(void)setCameraRightsForUser:(NSString *)newRights{
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"camera_id"],@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"email"],@"email",newRights,@"rights", nil],@"Post_Param", nil];
    [EvercamShare updateUserRights:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"%@",details);
            [self.loadingActivityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(void)blockAccessOfUser{
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userDictionary[@"camera_id"],@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",userDictionary[@"email"],@"user_Email", nil];
    [EvercamShare deleteCameraShare:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"%@",details);
            [self.loadingActivityIndicator stopAnimating];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.loadingActivityIndicator stopAnimating];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:@"Something went wrong. Please try again."];
        }
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
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
