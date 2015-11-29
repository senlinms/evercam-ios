//
//  AddCameraViewController.h
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamCamera.h"
#import "GAI.h"

@protocol ViewCameraViewControllerDelegate <NSObject>
- (void)cameraDeleted:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface ViewCameraViewController : GAITrackedViewController

@property (nonatomic, strong) EvercamCamera *camera;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextView *txtID;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblOwner;
@property (weak, nonatomic) IBOutlet UILabel *lblTimezone;
@property (weak, nonatomic) IBOutlet UILabel *lblVendor;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblPassword;
@property (weak, nonatomic) IBOutlet UITextView *tvSnapshot;
@property (weak, nonatomic) IBOutlet UITextView *tvRTSPURL;
@property (weak, nonatomic) IBOutlet UILabel *lblExternalHost;
@property (weak, nonatomic) IBOutlet UILabel *lblExternalHTTPPort;
@property (weak, nonatomic) IBOutlet UILabel *lblExternalRTSPPort;
@property (weak, nonatomic) IBOutlet UILabel *lblInternalHost;
@property (weak, nonatomic) IBOutlet UILabel *lblInternalHTTPPort;
@property (weak, nonatomic) IBOutlet UILabel *lblInternalRTSPPort;

@property (weak, nonatomic) IBOutlet UIView *editContainerView;

@property (nonatomic, strong) id<ViewCameraViewControllerDelegate> delegate;

@end
