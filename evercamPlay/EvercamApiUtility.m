//
//  EvercamApiUtility.m
//  evercamPlay
//
//  Created by Zulqarnain on 7/22/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "EvercamApiUtility.h"

@implementation EvercamApiUtility

+(EvercamApiUtility *)sharedLRUtility
{
    static EvercamApiUtility *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EvercamApiUtility alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(EvercamApiUtility *)init
{
    NSLog(@"LRUtility Init Called");
    if ((self = [super init])) {
        
        
        
    }
    return self;
}

-(NSMutableURLRequest *)createRequestWithUrl:(NSString *)urlString withType:(NSString *)httpMethod{
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:httpMethod];
    return request;
    
}

-(void)createErrorFromApi:(NSData *)responseData withStatusCode:(NSInteger)statusCode withBlock:(void (^) (NSError *error))block{
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSError *customError = nil;
    if ([responseDictionary[@"message"] isKindOfClass:[NSString class]]) {
        
        customError = [NSError errorWithDomain:@"api.evercam.io" code:statusCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:responseDictionary[@"message"],NSLocalizedDescriptionKey, nil]];
        
    }else{
        if (!responseDictionary) {
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Something went wrong. Please try again." };
            customError  = [NSError errorWithDomain:@"api.evercam.io" code:statusCode userInfo:errorDictionary];
        }else{
            NSDictionary *messageDict = responseDictionary[@"message"];
            NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : messageDict[[messageDict allKeys][0]][0] };
            customError  = [NSError errorWithDomain:@"api.evercam.io" code:statusCode userInfo:errorDictionary];
        }
        
    }
    
    if (block) {
        block(customError);
    }
    
}
@end
