//
//  ShareViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 5/9/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareCell.h"
#import "EvercamShare.h"
#import "EvercamSingleCameraDetails.h"
#import "AppDelegate.h"
#import "EvercamUtility.h"
#import "GlobalSettings.h"
#import "ShareSettingViewController.h"
#import "NewShareViewController.h"
#import "ActionSheetPicker.h"
@interface ShareViewController (){
    NSMutableArray *shareArray;
    NSArray *transferArray;
}

@end

@implementation ShareViewController
@synthesize camera_Object;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.usersTableView registerNib:[UINib nibWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ShareCell":@"ShareCell_iPad" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    if (![GlobalSettings sharedInstance].isPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getcameraDetails) name:@"K_ISIPAD_DEVICE" object:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (AppUtility.isFullyDismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        shareArray = [NSMutableArray new];
        [self getcameraDetails];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getcameraDetails{
    if (AppUtility.isFullyDismiss) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [shareArray removeAllObjects];
    self.view.userInteractionEnabled = NO;
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:camera_Object.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    [self.loading_ActivityIndicator startAnimating];
    [EvercamSingleCameraDetails getCameraDetails:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSDictionary *camDict = details;
            NSArray *cameraObjectArray = camDict[@"cameras"];
            camera_Object = [[EvercamCamera alloc] initWithDictionary:cameraObjectArray[0]];
            [self setCameraStatusValues];
            [self getCameraUsers:param_Dictionary];
        }else{
            self.view.userInteractionEnabled = YES;
            [self showErrorMessage];
        }
    }];
}

-(void)getCameraUsers:(NSDictionary *)param_Dictionary{
    [EvercamShare getCameraShareDetails:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSDictionary *shareDetailDict = (NSDictionary *)details;
            [shareArray addObjectsFromArray:shareDetailDict[@"shares"]];
            AppUser *user = [APP_DELEGATE defaultUser];
            NSLog(@"Current User email: %@",user.email);
            if ([shareDetailDict[@"owner"][@"email"] isEqualToString:user.email]) {
                self.transferBtn.hidden = NO;
                self.addShareBtn.frame = CGRectMake(self.transferBtn.frame.origin.x - self.addShareBtn.frame.size.width, self.addShareBtn.frame.origin.y, self.addShareBtn.frame.size.width, self.addShareBtn.frame.size.height);
                transferArray = shareDetailDict[@"shares"];
            }else{
                self.transferBtn.hidden = YES;
                self.addShareBtn.frame = CGRectMake(self.transferBtn.frame.origin.x, self.addShareBtn.frame.origin.y, self.addShareBtn.frame.size.width, self.addShareBtn.frame.size.height);
            }
            [shareArray insertObject:shareDetailDict[@"owner"] atIndex:0];
            [self getPendingRequest:param_Dictionary];
        }else{
            self.view.userInteractionEnabled = YES;
            [self showErrorMessage];
        }
    }];
}


-(void)getPendingRequest:(NSDictionary *)param_Dictionary{
    [EvercamShare getCameraPendingRequest:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [self.loading_ActivityIndicator stopAnimating];
            self.view.userInteractionEnabled = YES;
            NSDictionary *shareDetailDict = (NSDictionary *)details;
            [shareArray addObjectsFromArray:shareDetailDict[@"share_requests"]];
            [self.usersTableView reloadData];
        }else{
            self.view.userInteractionEnabled = YES;
            [self showErrorMessage];
        }
    }];
}

-(void)showErrorMessage{
    [self.loading_ActivityIndicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)setCameraStatusValues{
    if (!camera_Object.is_Public && !camera_Object.is_Discoverable) {
        self.camera_Status_Label.text       = @"Is Public: [No] & Discoverable: [No]";
        self.camera_Status_MainLabel.text   = @"Only specific users";
    }else if (!camera_Object.is_Public && camera_Object.is_Discoverable){
        self.camera_Status_Label.text       = @"Is Public: [No] & Discoverable: [Yes]";
        self.camera_Status_MainLabel.text   = @"Anyone with the link";
    }else if (camera_Object.is_Public && camera_Object.is_Discoverable){
        self.camera_Status_Label.text       = @"Is Public: [Yes] & Discoverable: [Yes]";
        self.camera_Status_MainLabel.text   = @"Public on the web";
    }
}

#pragma UIALERTVIEW DELEGATE
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 5607) {
        if (buttonIndex == 1) {
            [ActionSheetStringPicker showPickerWithTitle:@"Select a new owner" rows:[transferArray valueForKey:@"fullname"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:camera_Object.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",[NSDictionary dictionaryWithObjectsAndKeys:(NSDictionary *)transferArray[selectedIndex][@"email"],@"user_id", nil],@"Post_Param", nil];
                [self.loading_ActivityIndicator startAnimating];
                [EvercamShare transferCameraOwner:param_Dictionary withBlock:^(id details, NSError *error) {
                    if (!error) {
                        [self.loading_ActivityIndicator stopAnimating];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [self showErrorMessage];
                    }
                }];
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            } origin:self.transferBtn];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shareArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *dict = shareArray[indexPath.row];
    cell.name_Label.text    = (dict[@"fullname"])?dict[@"fullname"]:dict[@"email"];
    cell.email_Label.text   = (dict[@"fullname"])?dict[@"email"]:@"...pending";
    cell.rights_Label.text  = (indexPath.row == 0)?@"Owner":[AppUtility getCameraRights:dict[@"rights"]];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [AppUtility colorWithHexString:@"f5f5f5"];
    cell.selectedBackgroundView = selectionColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        ShareSettingViewController *sSVC = [[ShareSettingViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ShareSettingViewController":@"ShareSettingViewController_iPad" bundle:[NSBundle mainBundle]];
        if (![GlobalSettings sharedInstance].isPhone) {
           sSVC.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        sSVC.userDictionary = shareArray[indexPath.row];
        sSVC.isUserRights   = YES;
        sSVC.isPendingUser  = (sSVC.userDictionary[@"fullname"])?NO:YES;
        ([GlobalSettings sharedInstance].isPhone)? [self.navigationController pushViewController:sSVC animated:YES]:[self presentViewController:sSVC animated:YES completion:NULL];
    }
    
}

- (IBAction)camera_StatusChange_Action:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.cam_status_View.backgroundColor = [AppUtility colorWithHexString:@"f5f5f5"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
           self.cam_status_View.backgroundColor = [UIColor whiteColor]; 
        }];
        ShareSettingViewController *sSVC = [[ShareSettingViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ShareSettingViewController":@"ShareSettingViewController_iPad" bundle:[NSBundle mainBundle]];
        sSVC.isUserRights   = NO;
        sSVC.isPendingUser  = NO;
        sSVC.rightsString   = self.camera_Status_MainLabel.text;
        sSVC.cameraId       = camera_Object.camId;
        [self.navigationController pushViewController:sSVC animated:YES];
    }];
}

- (IBAction)transferOwnerAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transfer Camera Ownership" message:@"Transfer ownership to a user who you are already sharing the camera with.\n Once you Transfer, you may lose all rights to the camera and associated artifacts." delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"TRANSFER", nil];
    alert.tag = 5607;
    [alert show];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)NewShareAction:(id)sender {
    NewShareViewController *sSVC    = [[NewShareViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"NewShareViewController":@"NewShareViewController_iPad" bundle:[NSBundle mainBundle]];
    if (![GlobalSettings sharedInstance].isPhone) {
        sSVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    sSVC.cameraId                   = camera_Object.camId;
    ([GlobalSettings sharedInstance].isPhone)? [self.navigationController pushViewController:sSVC animated:YES]:[self presentViewController:sSVC animated:YES completion:NULL];
//    [self.navigationController pushViewController:sSVC animated:YES];
}

@end
