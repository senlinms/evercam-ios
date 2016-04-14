//
//  FeedbackViewController.h
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface FeedbackViewController : GAITrackedViewController{
    BOOL isFromLiveCameraView;
}

@property (nonatomic,assign) BOOL isFromLiveCameraView;

@property (nonatomic, strong) NSString *cameraID;

@property (nonatomic, retain) IBOutlet UIScrollView *contentView;
@property (nonatomic, strong) IBOutlet UITextField *txt_username;
@property (nonatomic, strong) IBOutlet UITextField *txt_email;
@property (nonatomic, strong) IBOutlet UITextField *txt_feedback;

@end
