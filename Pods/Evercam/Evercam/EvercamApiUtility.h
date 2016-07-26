//
//  EvercamApiUtility.h
//  evercamPlay
//
//  Created by Zulqarnain on 7/22/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APIUtility [EvercamApiUtility sharedLRUtility]

#define KBASEURL @"https://media.evercam.io/v1/"

@interface EvercamApiUtility : NSObject{
    
}
+(EvercamApiUtility *)sharedLRUtility;


-(NSMutableURLRequest *)createRequestWithUrl:(NSString *)urlString withType:(NSString *)httpMethod;

-(void)createErrorFromApi:(NSData *)responseData withStatusCode:(NSInteger)statusCode withBlock:(void (^) (NSError *error))block;
@end
