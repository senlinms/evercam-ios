//
//  AddPresetViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 5/24/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPresetViewController : UIViewController<UITextFieldDelegate>{
    NSString *cameraId;
}
@property (nonatomic,strong) NSString *cameraId;

- (IBAction)backAction:(id)sender;
- (IBAction)addPreset:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
