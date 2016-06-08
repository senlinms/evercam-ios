//
//  AllDevicesCell.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/2/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllDevicesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ipAddress_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *macAddress_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *deviceName_Lbl;
@property (weak, nonatomic) IBOutlet UIButton *reportBtn;
@end
