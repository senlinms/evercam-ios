//
//  CameraPlayViewController.h
//  evercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "EvercamCamera.h"
//#import "EaglUIView.h" //LD
#import "GAI.h"
#import "NIDropdown.h"

@protocol CameraPlayViewControllerDelegate <NSObject>

- (void)cameraDeleted:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface CameraPlayViewController : GAITrackedViewController<NIDropDownDelegate> {
//    IBOutlet EaglUIView *video_view; //LD
}

@property (weak, nonatomic) IBOutlet UILabel *lblTimeCode;
@property (weak, nonatomic) IBOutlet UILabel *lblOffline;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIImageView *downImgView;
@property (weak, nonatomic) IBOutlet UIView *titlebar;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) AsyncImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *confirmInsideView;

@property (nonatomic, strong) EvercamCamera *cameraInfo;
@property (nonatomic, strong) NSArray *cameras;

@property (nonatomic, strong) id<CameraPlayViewControllerDelegate> delegate;

@end
