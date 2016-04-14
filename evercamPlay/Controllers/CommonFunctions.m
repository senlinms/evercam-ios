//
//  CommonFunctions.m
//  evercamPlay
//
//  Created by Vocal Matrix on 26/10/2015.
//  Copyright © 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonFunctions.h"
#import "AFHTTPRequestOperationManager.h"



NSString* SendRequest(NSString* ip, NSString* port)
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSDictionary *params = @{@"ip": ip,
                            //@"port": port};
    [manager POST:@"http://192.168.1.26/projects" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    return @"";
}


//NSString* SendRequest(NSString* ip, int* port)
//{
//    // http://tuq.in/tools/port.txt?ip=5.149.169.19&port=22
//    NSURL *url = [NSURL URLWithString:@"http://tuq.in/tools/port.txt?ip= %@ & port=%@",ip port];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    NSURLResponse *response;
//    NSError *error;
//    //send it synchronous
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    // check for an error. If there is a network error, you should handle it here.
//    if(!error)
//    {
//        //log response
//        NSLog(@"Response from server = %@", responseString);
//    }
//    return @"";
//
//}



//NSString* getDocPath(NSString* filename)
//{
//    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
//    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
//    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:filename];
//    return documentDirectoryFilename;
//}

