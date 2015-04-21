//
//  AsyncImageView.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


//
//

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIImageView {
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *urlString; // key for image cache dictionary
}

+(void) releaseCacheMemory;
-(void) displayImage:(UIImage *)image;
-(void) loadImageFromURL:(NSURL*)url withSpinny:(BOOL)hasSpinny;
-(void) drawImage:(UIImage*)image;
-(void) stopLoadingImage;

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) UIActivityIndicatorView *spinny;
@property (nonatomic, strong) UIImage *offlineImage;
@property (nonatomic, strong) UIView *secondaryView;

@end
