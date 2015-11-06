//
//  SharedManager.m
//  evercamPlay
//
//  Created by Vocal Matrix on 26/10/2015.
//  Copyright © 2015 evercom. All rights reserved.
//

#import "SharedManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "EvercamShell.h"
#import "AppDelegate.h"

@implementation SharedManager

+(NSString*)getCheckPortUrl
{
    return @"http://tuq.in/tools/port.txt";
}

+(NSString*)getIPUrl
{
    return @"http://ipinfo.io/ip";
}

+(void)get:(NSString*)url params:(NSDictionary*)params callback:(void (^)(NSString* status, NSMutableDictionary* responseObject))callback
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary* dict = [NSMutableDictionary new];
        
        NSError* error = nil;
        NSArray *arrayJson = [NSArray arrayWithObjects:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error],nil];
        if(error){
            error = nil;
            NSDictionary *dictJson = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            if(error){
                NSString* newStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                [dict setObject:newStr forKey:@"JSON"];
                
            }
            else {
                [dict setObject:dictJson forKey:@"JSON"];
            }
        }
        else {
            [dict setObject:arrayJson forKey:@"JSON"];
        }
        
        callback(@"success", dict);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSMutableDictionary* dict = [NSMutableDictionary new];
        [dict setObject:[error userInfo] forKey:@"JSON"];
        callback(@"error", dict);
    }];
}




//+(void)getCameraName
//{
//    NSString* cameraName;
//    
//    [[EvercamShell shell] getAllCameras:[APP_DELEGATE defaultUser].username includeShared:YES includeThumbnail:YES withBlock:^(NSArray *cameras, NSError *error) {
//        //        [self hideLoadingView];
//        if (error == nil)
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                EvercamCamera* camera = [cameras firstObject];
//                NSLog(@"%@",camera);
//                
//                //NSLog(@"%@", camera.name);
//                cameraName = camera.name;
//            
//                
////                NSMutableArray* cameraNamesArray = [[NSMutableArray alloc] init];
////                                id num = "".join($1.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)).toInt() {
////                                        return $0 + [num]
////                                    }
////                
////                
////                
////                                NSMutableArray *mArray = [[NSMutableArray alloc]init];
////                                for (NSString *string in array) {
////                                    NSMutableString *string1 = [[NSMutableString alloc]init];
////                                    for (NSString *str in [string componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]) {
////                                        [string1 appendString:str];
////                                    }
////                                    [mArray addObject:string1];
////                                }
//                
//                
//                
//                
//                
//                /*  example
//                 let arr = ["55a", "95a", "66", "25", "88b", "#"]
//                 let numbers: [Int] = arr.reduce([]) {
//                 if let num = "".join($1.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)).toInt() {
//                 return $0 + [num]
//                 }
//                 
//                 return $0
//                 }
//                 
//                 minElement(numbers) // 25
//                 maxElement(numbers) // 95
//                 */
//                
//                //                for (EvercamCamera *cam in cameras) {
//                ////                    if (cam.isOnline == YES) {
//                ////
//                ////                    }
//                //                }
//            });
//        }
//        else
//        {
//            NSLog(@"Error %li: %@", (long)error.code, error.localizedDescription);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ops!" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alertView show];
//            });
//        }
//    }];
//    
//}




@end
