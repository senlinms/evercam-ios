//
//  SettingsViewController.h
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface SettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;


@end
