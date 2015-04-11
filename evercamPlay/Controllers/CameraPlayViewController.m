//
//  CameraPlayViewController.m
//  evercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "CameraPlayViewController.h"
#import "EvercamShell.h"
#include "gst-launch-remote.h"
#import "PreferenceUtil.h"
#import "CustomNavigationController.h"
#import "AppDelegate.h"

@interface CameraPlayViewController () {
    GstLaunchRemote *launch;
    int media_width;
    int media_height;
    Boolean dragging_slider;
    Boolean viewClosed;
}

@end

@implementation CameraPlayViewController

static void set_message_proxy (const gchar *message, gpointer app)
{
    CameraPlayViewController *self = (__bridge CameraPlayViewController *) app;
    [self setMessage:[NSString stringWithUTF8String:message]];
}

void set_current_position_proxy (gint position, gint duration, gpointer app)
{
    CameraPlayViewController *self = (__bridge CameraPlayViewController *) app;
    [self setCurrentPosition:position duration:duration];
}

void initialized_proxy (gpointer app)
{
    CameraPlayViewController *self = (__bridge CameraPlayViewController *) app;
    [self initialized];
}

void media_size_changed_proxy (gint width, gint height, gpointer app)
{
    CameraPlayViewController *self = (__bridge CameraPlayViewController *) app;
    [self mediaSizeChanged:width height:height];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblName.text = self.cameraInfo.name;
    [self playCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [self disableSleep];
    
    int sleepTimerSecs = [PreferenceUtil getSleepTimerSecs];
    [self performSelector:@selector(enableSleep) withObject:nil afterDelay:sleepTimerSecs];
    
    BOOL isForceLandscape = [PreferenceUtil isForceLandscape];
    if (isForceLandscape) {
        [(CustomNavigationController *)self.navigationController setIsPortraitMode:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self enableSleep];
    [(CustomNavigationController *)self.navigationController setIsPortraitMode:NO];
}

- (void)disableSleep {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)enableSleep {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc {
    if (launch)
    {
        gst_launch_remote_free(launch);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    viewClosed = true;
    
}

- (void)playCamera {
    if ([self.cameraInfo isOnline]) {
        self.lblOffline.hidden = YES;
        self.imageView.hidden = NO;
        [self.imageView loadImageFromURL:[NSURL URLWithString:self.cameraInfo.thumbnailUrl]];
        
        if (self.cameraInfo.externalH264Url && self.cameraInfo.externalH264Url.length > 0) {
            [self createPlayer];
        } else {
            [self createBrowseJpgTask];
        }
        
    } else {
        self.lblOffline.hidden = NO;
        self.imageView.hidden = YES;
    }
}

- (void)createPlayer {
    GstLaunchRemoteAppContext ctx;
    ctx.app = (__bridge gpointer)(self);
    ctx.initialized = initialized_proxy;
    ctx.media_size_changed = media_size_changed_proxy;
    ctx.set_current_position = set_current_position_proxy;
    ctx.set_message = set_message_proxy;
    
    launch = gst_launch_remote_new(&ctx);
    
    NSString *pipeline = [NSString stringWithFormat:@"rtspsrc protocols=4  location=%@ user-id=%@ user-pw=%@ latency=0 drop-on-latency=1 ! decodebin ! videoconvert ! autovideosink", self.cameraInfo.externalH264Url, self.cameraInfo.username, self.cameraInfo.password];
    launch->real_pipeline_string = (gchar *)[pipeline UTF8String];
//    launch->real_pipeline_string = "rtspsrc protocols=4  location=rtsp://89.101.130.1:9021/h264/ch1/main/av_stream user-id=admin user-pw=mehcam latency=0 drop-on-latency=1 ! decodebin ! videoconvert ! autovideosink";
    
    gst_launch_remote_set_window_handle(launch, (guintptr) (id) video_view);
}

- (void)createBrowseJpgTask {
    if (viewClosed) {
        return;
    }
    
    [[EvercamShell shell] getSnapshotFromCamId:self.cameraInfo.camId withBlock:^(NSData *imgData, NSError *error) {
        if (error == nil && imgData != nil) {
            [self.imageView setImage:[UIImage imageWithData:imgData]];
            self.imageView.hidden = NO;
            
            [self createBrowseJpgTask];
        }
    }];
}

#pragma mark - Gstreamer callback functions

-(void) initialized {
    NSLog(@"initialized");
    gst_launch_remote_play(launch);
}

-(void) setMessage:(NSString *)message {
    NSLog(@"setMessage:%@", message);
    
    if ([message hasPrefix:@"Error received from element"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createBrowseJpgTask];
        });
    }
}

-(void) setCurrentPosition:(NSInteger)position duration:(NSInteger)duration {

}

-(void) mediaSizeChanged:(NSInteger)width height:(NSInteger)height
{
    media_width = width;
    media_height = height;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.hidden = YES;
        [self viewDidLayoutSubviews];
        [video_view setNeedsLayout];
        [video_view layoutIfNeeded];
    });
}

@end
