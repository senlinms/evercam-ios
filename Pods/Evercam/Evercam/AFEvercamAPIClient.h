// AFEvercamAPIClient.h
//
// Copyright (c) 2012 Mattt Thompson (http://mattt.me/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

#define MSG_API_KEY_REQUIRED @"Developer API key and API ID required"
#define MSG_USER_API_KEY_REQUIRED @"User API key and API ID required"
#define MSG_INVALID_USER_KEY @"Invalid user api key/id"
#define MSG_INVALID_DEVELOPER_KEY @"Invalid developer api key/id"
#define MSG_INVALID_AUTH @"Invalid auth"
#define MSG_SERVER_ERROR @"Evercam internal server error."

#define CODE_OK 200
#define CODE_CREATE 201
#define CODE_UNAUTHORISED 401
#define CODE_FORBIDDEN 403
#define CODE_ERROR 400
#define CODE_NOT_FOUND 404
#define CODE_CONFLICT 409
#define CODE_SERVER_ERROR 500

@interface AFEvercamAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;
- (NSString *)baseUrl;

@end
