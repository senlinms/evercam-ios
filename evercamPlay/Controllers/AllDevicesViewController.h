//
//  AllDevicesViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/2/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllDevicesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *devicesArray;
}
@property (nonatomic,strong) NSMutableArray *devicesArray;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;
- (IBAction)backAction:(id)sender;

@end
