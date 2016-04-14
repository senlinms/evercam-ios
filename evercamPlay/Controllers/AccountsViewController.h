//
//  AccountsViewController.h
//  EvercamPlay
//
//  Created by jw on 3/9/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "AddAccountView.h"

@interface AccountsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, AddAccountViewDelegate>

@property (nonatomic, strong) AddAccountView *addAccountView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *btnMenu;
@end
