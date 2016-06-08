//
//  ReportCameraViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/6/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalSettings.h"
#import "Device.h"
@interface ReportCameraViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    
}
- (IBAction)backAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
- (IBAction)reportModel:(id)sender;

@end
