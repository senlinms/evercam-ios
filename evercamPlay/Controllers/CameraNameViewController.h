//
//  CameraNameViewController.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/13/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface CameraNameViewController : UIViewController{
    NSMutableDictionary *postDictionary;
}
@property (nonatomic, strong) NSMutableDictionary *postDictionary;
@property (weak, nonatomic) IBOutlet UITextField *nametextField;
- (IBAction)doneAction:(id)sender;
- (IBAction)backAction:(id)sender;
@end
