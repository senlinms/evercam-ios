//
//  BrowseJpgTask.h
//  EvercamPlay
//
//  Created by jw on 4/14/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvercamCamera.h"

@interface BrowseJpgTask : NSObject {
    BOOL stopped;
}

- (void)start;
- (void)stop;

@property (nonatomic) EvercamCamera *cameraInfo;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

- (id)initWithCamera:(EvercamCamera *)camera andImageView:(UIImageView *)imageView andLoadingView:(UIActivityIndicatorView *)loadingView;

@end
