//
//  CameraScanViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/1/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanLAN.h"
#import "GCDAsyncUdpSocket.h"
@interface CameraScanViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ScanLANDelegate,GCDAsyncUdpSocketDelegate,NSXMLParserDelegate,UIAlertViewDelegate>{

}
@property (weak, nonatomic) IBOutlet UITableView *camera_Table;
- (IBAction)backAction:(id)sender;
- (IBAction)scan_Other_Devices:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanning_activityindicator;
@property (weak, nonatomic) IBOutlet UIButton *otherDevicesBtn;
@property (weak, nonatomic) IBOutlet UILabel *cautionLabel;
- (IBAction)addCamera:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addCameraBtn;

@end
