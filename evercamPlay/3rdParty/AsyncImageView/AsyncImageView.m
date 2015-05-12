//
//  AsyncImageView.m
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"
#import "ImageCacheObject.h"
#import "ImageCache.h"
#import <QuartzCore/QuartzCore.h>

#define SPINNY_TAG 5555   

static ImageCache *imageCache = nil;

@implementation AsyncImageView
@synthesize spinny;

+ (void)releaseCacheMemory {
    if (imageCache) {
        [imageCache release];
        imageCache = nil;
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

-(void) stopLoadingImage {
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

- (void)displayImage:(UIImage *)image {
    self.imageURL = nil;
    [self setImage:image];
}

-(void)setImage:(UIImage*)image {
    
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
//    UIView *spinnyView = [self viewWithTag:SPINNY_TAG];
    if (spinny != nil) {
        [spinny removeFromSuperview];
        spinny = nil;
    }
    
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    [super setImage:image];
    
}

-(void)loadImageFromURL:(NSURL*)url withSpinny:(BOOL)hasSpinny {
    if (spinny != nil) {
        [spinny removeFromSuperview];
        spinny = nil;
    }
    
    if ( !url )
        return;
    
    self.imageURL = url;
    
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) // lazily create image cache
        imageCache = [[ImageCache alloc] initWithMaxSize:5*1024*1024];  // 5 MB Image cache
    
    [urlString release];
    urlString = [[url absoluteString] copy];
    UIImage *cachedImage = [imageCache imageForKey:urlString];
    if (cachedImage != nil) {
        self.image = cachedImage;
        return;
    }else {
	}
    
    if (hasSpinny) {
        spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinny.tag = SPINNY_TAG;
        //spinny.center = self.center;
        spinny.frame = CGRectMake(self.frame.size.width/2-spinny.frame.size.width/2, self.frame.size.height/2-spinny.frame.size.height/2, spinny.frame.size.width, spinny.frame.size.height);
        
        [spinny startAnimating];
        [self addSubview:spinny];
        [spinny release];
    }
   
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    [connection release];
    connection = nil;
    
//    UIView *spinny = [self viewWithTag:SPINNY_TAG];
    if (spinny != nil) {
        [spinny removeFromSuperview];
        spinny = nil;
    }
    
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    
    self.image = [UIImage imageWithData:data];
    [imageCache insertImage:self.image withSize:[data length] forKey:urlString];
    
    [data release];
    data = nil;
    
    if (self.secondURL)
    {
        [self loadImageFromURL:self.secondURL withSpinny:NO];
        self.secondURL = nil;
    }
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    [connection release];
    connection = nil;
    
    if (spinny != nil) {
        [spinny removeFromSuperview];
        spinny = nil;
    }
    
    if ([[self subviews] count] > 0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    [data release];
    data = nil;
    
    [self setImage:self.offlineImage];
    [self.secondaryView setHidden:YES];
    
    if (self.secondURL)
    {
        [self loadImageFromURL:self.secondURL withSpinny:NO];
        self.secondURL = nil;
    }
}

@end
