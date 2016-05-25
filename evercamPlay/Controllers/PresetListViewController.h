//
//  PresetListViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PresetListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSString *cameraID;
}

@property(nonatomic,strong) NSString *cameraID;

- (IBAction)back_Action:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *preset_TableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *caution_Label;
- (IBAction)addPreset:(id)sender;

@end
