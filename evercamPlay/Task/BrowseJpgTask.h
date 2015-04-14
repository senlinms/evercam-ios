//
//  BrowseJpgTask.h
//  evercamPlay
//
//  Created by jw on 4/14/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvercamCamera.h"

@interface BrowseJpgTask : NSObject {
    BOOL stopped;
}

- (void)start;
- (void)stop;

@property (nonatomic) EvercamCamera *cameraInfo;
@property (nonatomic) UIImageView *imageView;

- (id)initWithCamera:(EvercamCamera *)camera andImageView:(UIImageView *)imageView;

@end
