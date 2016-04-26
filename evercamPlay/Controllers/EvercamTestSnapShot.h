//
//  EvercamTestSnapShot.h
//  evercamPlay
//
//  Created by NainAwan on 15/04/2016.
//  Copyright © 2016 evercom. All rights reserved.
//

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif
@interface EvercamTestSnapShot : NSObject
+(void)testSnapShot:(NSDictionary *)parameterDictionary withBlock:(void (^) (UIImage *snapeImage,NSString *statusMessage,NSError *error))block;
@end
