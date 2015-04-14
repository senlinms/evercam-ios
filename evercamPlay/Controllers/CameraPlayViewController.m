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
#import "ViewCameraViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "BrowseJpgTask.h"

@interface CameraPlayViewController () <ViewCameraViewControllerDelegate> {
    GstLaunchRemote *launch;
    int media_width;
    int media_height;
    Boolean dragging_slider;
    BrowseJpgTask *browseJpgTask;
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [self enableSleep];
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
    
    if (browseJpgTask) {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
}

- (void)showCameraView {
    ViewCameraViewController *viewCameraVC = [[ViewCameraViewController alloc] initWithNibName:@"ViewCameraViewController" bundle:nil];
    viewCameraVC.camera = self.cameraInfo;
    viewCameraVC.delegate = self;
    CustomNavigationController *viewCamNavVC = [[CustomNavigationController alloc] initWithRootViewController:viewCameraVC];
    viewCamNavVC.navigationBarHidden = YES;
    viewCamNavVC.isPortraitMode = YES;
    [self presentViewController:viewCamNavVC animated:YES completion:nil];
}

- (void)deleteCamera {
    if ([self.cameraInfo.rights canDelete]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EvercamShell shell] deleteCamera:self.cameraInfo.camId withBlock:^(BOOL success, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Camera deleted"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self back:nil];
                                         
                                         if ([self.delegate respondsToSelector:@selector(cameraDeleted:)]) {
                                             [self.delegate cameraDeleted:self.cameraInfo];
                                         }
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Failed to delete camera, please try again"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EvercamShell shell] deleteShareCamera:self.cameraInfo.camId andUserId:[APP_DELEGATE defaultUser].userId withBlock:^(BOOL success, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (success) {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Camera deleted"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self.navigationController popViewControllerAnimated:YES];
                                         
                                         if ([self.delegate respondsToSelector:@selector(cameraDeleted:)]) {
                                             [self.delegate cameraDeleted:self.cameraInfo];
                                         }
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle: nil
                                              message:@"Failed to delete camera, please try again"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (browseJpgTask) {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
}

- (IBAction)action:(id)sender {
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* viewDetails = [UIAlertAction
                          actionWithTitle:@"View Details"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [view dismissViewControllerAnimated:YES completion:nil];
                              [self showCameraView];
                              
                          }];
    UIAlertAction* removeCamera = [UIAlertAction
                           actionWithTitle:@"Remove Camera"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [view dismissViewControllerAnimated:YES completion:nil];
                               [self deleteCamera];
                               
                           }];
    
    UIAlertAction* savedImages = [UIAlertAction
                                   actionWithTitle:@"Saved Images"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    UIAlertAction* viewRecordings = [UIAlertAction
                                     actionWithTitle:@"View Recordings"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];

    UIAlertAction* localStorage = [UIAlertAction
                                   actionWithTitle:@"Local Storage"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];


    
    UIAlertAction* sendFeedback = [UIAlertAction
                                   actionWithTitle:@"Send Feedback"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [view addAction:viewDetails];
    [view addAction:removeCamera];
    [view addAction:savedImages];
    [view addAction:viewRecordings];
    if (self.cameraInfo.isHikvision && self.cameraInfo.hasCredentials) {
        [view addAction:localStorage];
    }
    [view addAction:sendFeedback];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (void)playCamera {
    if ([self.cameraInfo isOnline]) {
        self.lblOffline.hidden = YES;
        self.imageView.hidden = NO;
        [self.imageView loadImageFromURL:[NSURL URLWithString:self.cameraInfo.thumbnailUrl] withSpinny:NO];
        
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
    
    if (launch) {
        gst_launch_remote_free(launch);
    }
    launch = gst_launch_remote_new(&ctx);
    
    NSString *pipeline = [NSString stringWithFormat:@"rtspsrc protocols=4  location=%@ user-id=%@ user-pw=%@ latency=0 drop-on-latency=1 ! decodebin ! videoconvert ! autovideosink", self.cameraInfo.externalH264Url, self.cameraInfo.username, self.cameraInfo.password];
    launch->real_pipeline_string = (gchar *)[pipeline UTF8String];
//    launch->real_pipeline_string = "rtspsrc protocols=4  location=rtsp://89.101.130.1:9021/h264/ch1/main/av_stream user-id=admin user-pw=mehcam latency=0 drop-on-latency=1 ! decodebin ! videoconvert ! autovideosink";
    
    gst_launch_remote_set_window_handle(launch, (guintptr) (id) video_view);
}

- (void)createBrowseJpgTask {
    if (browseJpgTask) {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
    
    browseJpgTask = [[BrowseJpgTask alloc] initWithCamera:self.cameraInfo andImageView:self.imageView];
    [browseJpgTask start];
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

#pragma mark - ViewCameraViewController Delegate Method
- (void)cameraEdited:(EvercamCamera *)camera {
    self.cameraInfo = camera;
    [self playCamera];
    if ([self.delegate respondsToSelector:@selector(cameraEdited:)]) {
        [self.delegate cameraEdited:camera];
    }
}

@end
