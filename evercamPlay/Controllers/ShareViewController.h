//
//  ShareViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/9/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamCamera.h"
@interface ShareViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    
}


@property (nonatomic,strong) EvercamCamera  *camera_Object;

@property (weak, nonatomic) IBOutlet UIView *cam_status_View;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (weak, nonatomic) IBOutlet UILabel *camera_Status_Label;
@property (weak, nonatomic) IBOutlet UILabel *camera_Status_MainLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading_ActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *transferBtn;
@property (weak, nonatomic) IBOutlet UIButton *addShareBtn;

- (IBAction)camera_StatusChange_Action:(id)sender;
- (IBAction)transferOwnerAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *gravator_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *camera_Status_ImgView;

- (IBAction)backAction:(id)sender;
- (IBAction)NewShareAction:(id)sender;
@end
