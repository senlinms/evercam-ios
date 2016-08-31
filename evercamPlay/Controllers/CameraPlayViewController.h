//
//  CameraPlayViewController.h
//  EvercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "EvercamCamera.h"
#import "EaglUIView.h"
#import "GAI.h"
#import "NIDropdown.h"
#import "MyPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol CameraPlayViewControllerDelegate <NSObject>

- (void)cameraEdited:(EvercamCamera *)camera;
- (void)cameraDel:(EvercamCamera *)camera;

@end

@interface CameraPlayViewController : GAITrackedViewController<NIDropDownDelegate,UIActionSheetDelegate,UIScrollViewDelegate> {
    IBOutlet EaglUIView *video_view;
    BOOL isCameraRemoved;
    AVPlayer *player;
    AVPlayerItem *playerItem;
    id timeObserver;
}

@property (weak, nonatomic) IBOutlet MyPlayerLayerView *playerLayerView;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerItemVideoOutput* output;

@property (nonatomic,assign) BOOL isCameraRemoved;

@property (weak, nonatomic) IBOutlet UILabel        *lblTimeCode;
@property (weak, nonatomic) IBOutlet UILabel        *lblOffline;
@property (weak, nonatomic) IBOutlet UIButton       *btnTitle;
@property (weak, nonatomic) IBOutlet UIImageView    *downImgView;
@property (weak, nonatomic) IBOutlet UIView         *titlebar;
@property (weak, nonatomic) IBOutlet UIView         *playerView;
@property (strong, nonatomic) AsyncImageView        *imageView;

@property (weak, nonatomic) IBOutlet UIView         *confirmInsideView;
@property (weak, nonatomic) IBOutlet UIButton       *hiddenDropDownBtn;

@property (nonatomic, strong) EvercamCamera         *cameraInfo;
@property (nonatomic, strong) NSArray               *cameras;

@property (weak, nonatomic) IBOutlet UIScrollView *liveViewScroll;
@property (nonatomic, strong) id<CameraPlayViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture_outlet;
- (IBAction)pinchGestureAction:(id)sender;
//PTZ controls
- (IBAction)ptz_Controls_Action:(id)sender;

- (IBAction)dropDownImg_Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ptc_Control_View;
@property (weak, nonatomic) IBOutlet UIButton *presetBtn;
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *upBtn;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
- (IBAction)refreshAction:(id)sender;
@end
