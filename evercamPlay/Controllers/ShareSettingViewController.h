//
//  ShareSettingViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GravatarServiceFactory.h"
@interface ShareSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,GravatarServiceDelegate>{
    NSDictionary *userDictionary;
    BOOL isUserRights;
    BOOL isPendingUser;
    NSString *rightsString;
    NSString *cameraId;
}
@property (nonatomic,strong) NSString *cameraId;
@property (nonatomic,assign) BOOL isUserRights;
@property (nonatomic,assign) BOOL isPendingUser;
@property (nonatomic,strong) NSDictionary *userDictionary;
@property (nonatomic,strong) NSString *rightsString;
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;
@property (weak, nonatomic) IBOutlet UILabel *navigationBar_Label;
@property (weak, nonatomic) IBOutlet UIImageView *gravator_ImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rights_Segment;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *rights_View;

- (IBAction)backAction:(id)sender;
- (IBAction)save_Settings:(id)sender;
- (IBAction)resendShareRequest:(id)sender;

@end
