//
//  ShareSettingViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/11/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSettingViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    NSDictionary *userDictionary;
}

@property (nonatomic,strong) NSDictionary *userDictionary;

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

- (IBAction)backAction:(id)sender;
- (IBAction)save_Settings:(id)sender;

@end
