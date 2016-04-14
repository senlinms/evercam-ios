//
//  BrowseJpgTask.m
//  EvercamPlay
//
//  Created by jw on 4/14/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "BrowseJpgTask.h"
#import "EvercamShell.h"

@implementation BrowseJpgTask

- (id)initWithCamera:(EvercamCamera *)camera andImageView:(UIImageView *)imageView andLoadingView:(UIActivityIndicatorView *)loadingView {
    self = [super init];
    if (self) {
        self.cameraInfo = camera;
        self.imageView = imageView;
        self.loadingView = loadingView;
        stopped = YES;
    }
    return self;
}

- (void)start {
    if (stopped == YES)
    {
        stopped = NO;
       [self getSnapshot];
    }
}

- (void)stop {
    stopped = YES;
}

- (void)getSnapshot {
    if (stopped) {
        return;
    }
    
    [[EvercamShell shell] getSnapshotFromCamId:self.cameraInfo.camId withBlock:^(NSData *imgData, NSError *error) {
        if (self.loadingView)
            [self.loadingView stopAnimating];
        
        if (stopped == YES)
        {
//            [self.imageView setImage:nil];
            return;
        }
        
        if (error == nil && imgData != nil) {
            [self.imageView setImage:[UIImage imageWithData:imgData]];
            self.imageView.hidden = NO;
            
            [self getSnapshot];
        }
    }];
}

@end
