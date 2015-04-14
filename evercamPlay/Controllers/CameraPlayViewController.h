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
#import "EaglUIView.h"

@protocol CameraPlayViewControllerDelegate <NSObject>

- (void)cameraDeleted:(EvercamCamera *)camera;
- (void)cameraEdited:(EvercamCamera *)camera;

@end

@interface CameraPlayViewController : UIViewController {
    IBOutlet EaglUIView *video_view;
}

@property (weak, nonatomic) IBOutlet UILabel *lblOffline;
@property (weak, nonatomic) IBOutlet AsyncImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (nonatomic, strong) EvercamCamera *cameraInfo;

@property (nonatomic, strong) id<CameraPlayViewControllerDelegate> delegate;

@end
