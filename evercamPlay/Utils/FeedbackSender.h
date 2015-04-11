//
//  FeedbackSender.h
//  evercamPlay
//
//  Created by jw on 4/11/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackSender : NSObject

+ (void)sendWithFeedbackString:(NSString *)feedbackString andCameraId:(NSString *)cameraId;

@end
