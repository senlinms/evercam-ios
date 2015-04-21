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
#import "RecordingsViewController.h"
#import "FeedbackViewController.h"
#import "SnapshotViewController.h"
#import "CommonUtil.h"

@interface CameraPlayViewController () <ViewCameraViewControllerDelegate> {
    GstLaunchRemote *launch;
    int media_width;
    int media_height;
    Boolean dragging_slider;
    BrowseJpgTask *browseJpgTask;
    BOOL isPlaying;
    NIDropDown *dropDown;
    
    __weak IBOutlet UIButton *playOrPauseButton;
    __weak IBOutlet UIView *videoController;
    __weak IBOutlet UIButton *saveButton;
    
    __weak IBOutlet UIView *snapshotConfirmView;
    __weak IBOutlet UIImageView *imvSnapshot;
    __weak IBOutlet UIActivityIndicatorView *loadingView;
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
    
    self.screenName = @"Video View";
    
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
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

- (void)takeSnapshot {
    BOOL isDir;
    NSURL *documentsDirectory = [APP_DELEGATE applicationDocumentsDirectory];
    NSURL *snapshotDir = [documentsDirectory URLByAppendingPathComponent:self.cameraInfo.camId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:snapshotDir.path isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:snapshotDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *snapshotFileURL = [snapshotDir URLByAppendingPathComponent:[CommonUtil uuidString]];
    
    NSData *imgData = UIImageJPEGRepresentation(imvSnapshot.image, 1);
    [imgData writeToURL:snapshotFileURL atomically:YES];
}

- (void)showSnapshotView {
    [snapshotConfirmView setHidden:NO];
    
    if (self.imageView.hidden) {
        CGRect rect = [video_view bounds];
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [video_view.layer renderInContext:context];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imvSnapshot.image = img;
    } else {
        if (self.imageView.image) {
            imvSnapshot.image = self.imageView.image;
        } else {
            [snapshotConfirmView setHidden:YES];
        }
    }
}

- (void)hideSnapshotView {
    [snapshotConfirmView setHidden:YES];
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

- (void)sendFeedback {
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    feedbackVC.cameraID = self.cameraInfo.camId;

    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:feedbackVC];
    navVC.isPortraitMode = YES;
    navVC.navigationBarHidden = YES;

    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)showSavedImages {
    if ([CommonUtil snapshotFiles:self.cameraInfo.camId].count == 0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle: nil
                                      message:@"No snapshot saved for this camera."
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
    SnapshotViewController *snapshotVC = [[SnapshotViewController alloc] initWithNibName:@"SnapshotViewController" bundle:nil];
    snapshotVC.cameraId = self.cameraInfo.camId;
    CustomNavigationController *viewCamNavVC = [[CustomNavigationController alloc] initWithRootViewController:snapshotVC];
    viewCamNavVC.navigationBarHidden = YES;
    viewCamNavVC.isPortraitMode = YES;
    [self presentViewController:viewCamNavVC animated:YES completion:nil];
}

- (void)viewRecordings {
    RecordingsViewController *recordingsVC = [[RecordingsViewController alloc] initWithNibName:@"RecordingsViewController" bundle:nil];
    recordingsVC.cameraId = self.cameraInfo.camId;
    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:recordingsVC];
    navVC.isPortraitMode = YES;
    navVC.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)hideVideoController {
    videoController.hidden = YES;
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

- (IBAction)cameraItemTapped:(id)sender {
    NSMutableArray *cameraNameArray = [NSMutableArray new];
    NSMutableArray * arrImage = [[NSMutableArray alloc] init];
    
    for (EvercamCamera *camInfo in self.cameras) {
        [cameraNameArray addObject:camInfo.name];
        if (camInfo.isOnline) {
            [arrImage addObject:[UIImage imageNamed:@"icon_online.png"]];
        } else {
            [arrImage addObject:[UIImage imageNamed:@"icon_offline.png"]];
        }
    }
    
    if(dropDown == nil) {
        CGFloat f = 300;
        dropDown = [[NIDropDown alloc] showDropDown:sender height:&f textArray:cameraNameArray imageArray:arrImage direction:@"down"] ;
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }

}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (browseJpgTask) {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
}

- (IBAction)playOrPause:(id)sender {
    if (isPlaying) {
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        [self stopCamera];
    } else {
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
        [self playCamera];
    }
}
- (IBAction)handleSingleTap:(id)sender {
    if (![self.cameraInfo isOnline]) {
        return;
    }
    
    if ([loadingView isAnimating]) {
        return;
    }
    
    if (videoController.hidden) {
        videoController.hidden = NO;
        
        [self performSelector:@selector(hideVideoController) withObject:nil afterDelay:5];
    } else {
        videoController.hidden = YES;
    }
}

- (IBAction)snapshotCancel:(id)sender {
    [self hideSnapshotView];
}

- (IBAction)save:(id)sender {
    videoController.hidden = YES;
    [self showSnapshotView];
}

- (IBAction)snapshotSave:(id)sender {
    [self hideSnapshotView];
    [self takeSnapshot];
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
                                       [self showSavedImages];
                                       [view dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    UIAlertAction* viewRecordings = [UIAlertAction
                                     actionWithTitle:@"View Recordings"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                         [self viewRecordings];
                                         
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
                                       [self sendFeedback];
                                       
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
//    if (self.cameraInfo.isHikvision && self.cameraInfo.hasCredentials) {
//        [view addAction:localStorage];
//    }
    [view addAction:sendFeedback];
    [view addAction:cancel];
    
    [self presentViewController:view animated:YES completion:nil];
}

- (void)playCamera {
    [self.imageView displayImage:nil];
    if ([self.cameraInfo isOnline]) {
        self.lblOffline.hidden = YES;
        self.imageView.hidden = NO;
        [self.imageView loadImageFromURL:[NSURL URLWithString:self.cameraInfo.thumbnailUrl] withSpinny:NO];
        [loadingView startAnimating];
        
        if (self.cameraInfo.externalH264Url && self.cameraInfo.externalH264Url.length > 0) {
            [self createPlayer];
        } else {
            [self createBrowseJpgTask];
        }
        
    } else {
        self.lblOffline.hidden = NO;
        self.imageView.hidden = YES;
    }
    
    isPlaying = YES;
}

- (void)stopCamera {
    isPlaying = NO;
    
    if ([self.cameraInfo isOnline]) {
        if (launch)
        {
            gst_launch_remote_free(launch);
        }
        
        if (browseJpgTask) {
            [browseJpgTask stop];
            browseJpgTask = nil;
        }
    } else {
        return;
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
    
    browseJpgTask = [[BrowseJpgTask alloc] initWithCamera:self.cameraInfo andImageView:self.imageView andLoadingView:loadingView];
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
        [loadingView stopAnimating];
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

#pragma mark NIDropdown delegate
- (void) niDropDownDidSelectAtIndex: (NSInteger) index {
    dropDown = nil;
    self.cameraInfo = [self.cameras objectAtIndex:index];
    [self playCamera];
}

@end
