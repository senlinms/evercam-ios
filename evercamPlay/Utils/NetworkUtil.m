//
//  NetworkUtil.m
//  evercamPlay
//
//  Created by jw on 4/12/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#include <arpa/inet.h>
#import "NetworkUtil.h"
#import "Reachability.h"

@implementation NetworkUtil

+ (NSString *)getNetworkString {
    NetworkStatus networkStatus = [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        return @"WiFi";
    } else if (networkStatus == ReachableViaWWAN) {
        return @"3G";
    } else {
        return @"";
    }
}

CFRunLoopSourceRef gSocketSource;
BOOL isPortReachable(NSString *url, NSInteger port) {
   
    //socket
    CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    CFSocketRef theSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack , (CFSocketCallBack)ConnectCallBack, &context);
    
    //address
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;
    socketAddress.sin_port = htons(port);
    socketAddress.sin_addr.s_addr = inet_addr([url UTF8String]);
    
    gSocketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, theSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), gSocketSource, kCFRunLoopDefaultMode);
    
    CFDataRef socketData = CFDataCreate(kCFAllocatorDefault, (const UInt8 *)&socketAddress, sizeof(socketAddress));
    CFSocketError status = CFSocketConnectToAddress(theSocket, socketData, 30); //30 second timeout
    //check status here
    CFRelease(socketData);
    if (status == kCFSocketSuccess) {
        return YES;
    } else {
        return NO;
    }
}

void ConnectCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    UInt8 buffer[1024];
    bzero(buffer, sizeof(buffer));
    CFSocketNativeHandle sock = CFSocketGetNative(socket); // The native socket, used recv()
    
    //check here for correct connect output from server
    recv(sock, buffer, sizeof(buffer), 0);
    printf("Output: %s\n", buffer);
    
    if (gSocketSource)
    {
        CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
        if (CFRunLoopContainsSource(currentRunLoop, gSocketSource, kCFRunLoopDefaultMode))
        {
            CFRunLoopRemoveSource(currentRunLoop, gSocketSource, kCFRunLoopDefaultMode);
        }
        CFRelease(gSocketSource);
    }
    
    if (socket) //close socket
    {
        if (CFSocketIsValid(socket))
        {
            CFSocketInvalidate(socket);
        }
        CFRelease(socket);
    }
}

@end
