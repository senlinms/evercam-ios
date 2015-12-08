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
#import "BlockActionSheet.h"
#import "GlobalSettings.h"

@interface CameraPlayViewController () <ViewCameraViewControllerDelegate> {
    GstLaunchRemote *launch;
    int media_width;
    int media_height;
    Boolean dragging_slider;
    BrowseJpgTask *browseJpgTask;
    BOOL isPlaying;
    NIDropDown *dropDown;
    NSTimer *timeCounter;
    NSString* currentImage;
    BOOL runFirstTime;
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
    runFirstTime = YES;
    videoController.alpha = 0.0;
    self.screenName = @"Video View";
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    [self playCamera];
    runFirstTime = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    //        self.playerView.frame = CGRectMake(0,72,self.playerView.frame.size.width, self.playerView.frame.size.height);
    
    self.statusbar.hidden = NO;
    self.titlebar.hidden = NO;
    self.btnTitle.hidden = NO;
    self.downImgView.hidden = NO;
    video_view.frame = CGRectMake(0, 0, self.playerView.frame.size.width,self.playerView.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
    [self disableSleep];
    
    long sleepTimerSecs = [PreferenceUtil getSleepTimerSecs];
    [self performSelector:@selector(enableSleep) withObject:nil afterDelay:sleepTimerSecs];
    
    self.statusbar.hidden = NO;
    self.titlebar.hidden = NO;
    self.btnTitle.hidden = NO;
    self.downImgView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self enableSleep];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation))
//    {
//        //LandscapeView
//        self.view.frame = CGRectMake(0,-20,self.view.frame.size.width, self.view.frame.size.height-20);
//        //      self.playerView.frame = CGRectMake(0,57,self.playerView.frame.size.width, self.playerView.frame.size.height);
////        self.titlebar.hidden = YES;
////        self.btnTitle.hidden = YES;
////        self.downImgView.hidden = YES;
//    }
//    else
//    {
//        self.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
//        //    self.playerView.frame = CGRectMake(0,72,self.playerView.frame.size.width, self.playerView.frame.size.height);
//        self.titlebar.hidden = NO;
//        self.btnTitle.hidden = NO;
//        self.downImgView.hidden = NO;
//    }
//}

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
        launch = nil;
    }
    
    if (timeCounter && [timeCounter isValid])
    {
        [timeCounter invalidate];
        timeCounter = nil;
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
    
    if (self.imageView == nil || self.imageView.hidden == YES) {
        CGRect rect = [video_view bounds];
        UIGraphicsBeginImageContext(rect.size);
        [video_view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        rect.origin.y = (rect.size.height - rect.size.width*media_height/media_width)/2;
        rect.size.height = rect.size.width*media_height/media_width;
        CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], rect);
        // or use the UIImage wherever you like
        [imvSnapshot setImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    } else {
        if (self.imageView && self.imageView.image) {
            CGFloat width = self.confirmInsideView.frame.size.width;
            CGFloat imgHeight = self.imageView.image.size.height*width/self.imageView.image.size.width;
            
            self.confirmInsideView.frame = CGRectMake(self.confirmInsideView.frame.origin.x,
                                                      self.confirmInsideView.frame.origin.y,
                                                      self.confirmInsideView.frame.size.width,
                                                      imgHeight + 41.0);
            
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
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"FeedbackViewController" : @"FeedbackViewController_iPad" bundle:nil];
    feedbackVC.cameraID = self.cameraInfo.camId;
    
    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:feedbackVC];
    navVC.isPortraitMode = YES;
    navVC.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)showSavedImages {
    if ([CommonUtil snapshotFiles:self.cameraInfo.camId].count == 0) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"No snapshot saved for this camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        
        return;
    }
    SnapshotViewController *snapshotVC = [[SnapshotViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SnapshotViewController" : @"SnapshotViewController_iPad" bundle:nil];
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
    [navVC setHasLandscapeMode:YES];
    navVC.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)hideVideoController {
    if (isPlaying == YES) {
        [self showVideoController:NO];
        //        videoController.hidden = YES;
    }
    else {
        [self showVideoController:YES];
        //        videoController.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showVideoController:(BOOL)willShow
{
    if (willShow == YES) {
        videoController.hidden = NO;
    }
    [UIView animateWithDuration:0.50f
                          delay:0.0f
                        options: UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         if (willShow == YES) {
                             videoController.alpha = 1.0;
                         }
                         else
                             videoController.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         if (willShow == NO) {
                             videoController.hidden = YES;
                         }
                     }
     ];
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
        CGFloat f = self.view.frame.size.height - ((UIButton*)sender).frame.origin.y - ((UIButton*)sender).frame.size.height;
        CGFloat h = (cameraNameArray.count * DropDownCellHeight);
        
        dropDown = [[NIDropDown alloc] showDropDown:sender height:(h<=f?&h: &f) textArray:cameraNameArray imageArray:arrImage direction:@"down"] ;
        dropDown.delegate = self;
    }
    else {
        [dropDown hideDropDown:sender];
        dropDown = nil;
    }
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (timeCounter && [timeCounter isValid])
    {
        [timeCounter invalidate];
        timeCounter = nil;
    }
    
    if (browseJpgTask) {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
}

- (IBAction)playOrPause:(id)sender {
    if (isPlaying) {
        //        [self.imageView setHidden:YES];
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        [self stopCamera];
    } else {
        [self showVideoController:NO];
        //        videoController.hidden = YES;
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
        [self playCamera];
    }
}
- (IBAction)handleSingleTap:(id)sender {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        //LandscapeView
        if (self.titlebar.hidden)
        {
            self.titlebar.hidden = NO;
            self.btnTitle.hidden = NO;
            self.downImgView.hidden = NO;
        }
        else
        {
            self.titlebar.hidden = YES;
            self.btnTitle.hidden = YES;
            self.downImgView.hidden = YES;
        }
    }
    
    if (dropDown)
    {
        [dropDown hideDropDown:self.btnTitle];
        dropDown = nil;
    }
    
    if (![self.cameraInfo isOnline]) {
        return;
    }
    
    if ([loadingView isAnimating]) {
        return;
    }
    
    if (videoController.hidden) {
        [self showVideoController:YES];
        //        videoController.hidden = NO;
        
        [self performSelector:@selector(hideVideoController) withObject:nil afterDelay:5];
    } else {
        if (isPlaying == YES) {
            [self showVideoController:NO];
            //    videoController.hidden = YES;
        }
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
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
        
        [sheet addButtonWithTitle:@"Camera Settings" block:^{
            [self showCameraView];
        }];
        [sheet addButtonWithTitle:@"Saved Images" block:^{
            [self showSavedImages];
        }];
        [sheet addButtonWithTitle:@"View Recordings" block:^{
            [self viewRecordings];
        }];
        [sheet addButtonWithTitle:@"Send Feedback" block:^{
            [self sendFeedback];
        }];
        
        [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
        [sheet showInView:self.view];
    }
    else
    {
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* viewDetails = [UIAlertAction
                                      actionWithTitle:@"Camera Settings"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
//                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [self showCameraView];
                                          
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
        [view addAction:savedImages];
        [view addAction:viewRecordings];
        [view addAction:sendFeedback];
        [view addAction:cancel];
        
        if ([GlobalSettings sharedInstance].isPhone)
        {
            [self presentViewController:view animated:YES completion:nil];
        }
        else
        {
            UIPopoverPresentationController *popPresenter = [view
                                                             popoverPresentationController];
            popPresenter.sourceView = (UIView *)sender;
            popPresenter.sourceRect = ((UIView *)sender).bounds;
            [self presentViewController:view animated:YES completion:nil];
        }
    }
}

- (void)playCamera {
    if (self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    if (browseJpgTask)
    {
        [browseJpgTask stop];
        browseJpgTask = nil;
    }
    
    if (timeCounter && [timeCounter isValid])
    {
        [timeCounter invalidate];
        timeCounter = nil;
    }
    
    self.lblTimeCode.hidden = YES;
    video_view.hidden = YES;
    
    if ([self.cameraInfo isOnline]) {
        self.lblOffline.hidden = YES;
        [loadingView startAnimating];
        
        if (self.cameraInfo.externalH264Url && self.cameraInfo.externalH264Url.length > 0) {
            [self createPlayer];
        } else {
            [self createBrowseJpgTask];
            if (runFirstTime) {
                [self.imageView loadImageFromURL:[NSURL URLWithString:self.cameraInfo.thumbnailUrl] withSpinny:NO];
            }
            else{
                self.imageView.image = [UIImage imageWithContentsOfFile:currentImage];
            }
        }
    } else {
        [loadingView stopAnimating];
        self.lblOffline.hidden = NO;
    }
    isPlaying = YES;
}


- (void)saveImage
{
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, self.imageView.layer.opaque, 0.0);
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *data=UIImagePNGRepresentation(img);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imgName = [NSString stringWithFormat:@"CurrentScreen.jpg"];
    NSString *strPath = [documentsDirectory stringByAppendingPathComponent:imgName];
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:strPath] == YES)
    {
        NSLog(@"file exist and I delete it");
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:strPath error:&error];
    }
        [data writeToFile:strPath atomically:YES];
        currentImage = strPath;
}

- (void)stopCamera {
    isPlaying = NO;
    [self saveImage];
    if ([self.cameraInfo isOnline]) {
        if (launch)
        {
            gst_launch_remote_pause(launch);
        }
        
        if (timeCounter && [timeCounter isValid])
        {
            [timeCounter invalidate];
            timeCounter = nil;
        }
        self.lblTimeCode.hidden = YES;
        
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
        gst_launch_remote_play(launch);
    }
    else
    {
        launch = gst_launch_remote_new(&ctx);
        NSString *pipeline = [NSString stringWithFormat:@"rtspsrc protocols=4  location=%@ user-id=%@ user-pw=%@ latency=0 drop-on-latency=1 ! decodebin ! videoconvert ! autovideosink", self.cameraInfo.externalH264Url, self.cameraInfo.username, self.cameraInfo.password];
        launch->real_pipeline_string = (gchar *)[pipeline UTF8String];
        
        gst_launch_remote_set_window_handle(launch, (guintptr) (id) video_view);
        
        
    }
    
}

- (void)createBrowseView {
    if (self.imageView)
    {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    self.imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, self.playerView.frame.size.width, self.playerView.frame.size.height)];
    self.imageView.autoresizingMask= UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.playerView addSubview:self.imageView];
    [self.playerView sendSubviewToBack:self.imageView];
}

- (void)createBrowseJpgTask {
    [self createBrowseView];
    browseJpgTask = [[BrowseJpgTask alloc] initWithCamera:self.cameraInfo andImageView:self.imageView andLoadingView:loadingView];
    [browseJpgTask start];
    
    self.lblTimeCode.hidden = NO;
    timeCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeCode) userInfo:nil repeats:YES];
}

#pragma mark Timer
-(void) updateTimeCode
{
    NSDate *theDate = [NSDate date];
    NSDateFormatter *userFormatter = [[NSDateFormatter alloc] init];
    [userFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    [userFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.cameraInfo.timezone]];
    NSString *dateConverted = [userFormatter stringFromDate:theDate];
    self.lblTimeCode.text = dateConverted;
}

#pragma mark - Gstreamer callback functions

-(void) initialized {
    NSLog(@"initialized");
    gst_launch_remote_play(launch);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timeCounter && [timeCounter isValid])
        {
            [timeCounter invalidate];
            timeCounter = nil;
        }
        timeCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeCode) userInfo:nil repeats:YES];
    });
}

-(void) setMessage:(NSString *)message {
    NSLog(@"setMessage:%@", message);
    if ([message hasPrefix:@"State changed to PLAYING"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            video_view.hidden = NO;
            self.lblTimeCode.hidden = NO;
        });
    }
    if ([message hasPrefix:@"Error received from element"] ||
        [message hasPrefix:@"Failed to set pipeline to PLAYING"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView startAnimating];
            [self createBrowseJpgTask];
            [self.imageView loadImageFromURL:[NSURL URLWithString:self.cameraInfo.thumbnailUrl] withSpinny:NO];
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
        [loadingView stopAnimating];
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

#pragma mark - CameraPlayViewController Delegate Method
- (void)cameraDeleted:(EvercamCamera *)camera {
    [self back:self];
    [self.delegate cameraDel:camera];
}


#pragma mark NIDropdown delegate
- (void) niDropDown:(NIDropDown*)dropdown didSelectAtIndex:(NSInteger)index {
    if (launch) {
        gst_launch_remote_free(launch);
        launch = nil;
    }
    dropDown = nil;
    self.cameraInfo = [self.cameras objectAtIndex:index];
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    [self playCamera];
    runFirstTime = YES;
}

@end
