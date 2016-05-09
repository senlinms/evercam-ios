
//
//  CameraPlayViewController.m
//  EvercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
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
#import "SnapshotViewController.h"
#import "CommonUtil.h"
#import "BlockActionSheet.h"
#import "GlobalSettings.h"
#import <PhoenixClient/PhoenixClient.h>
#import <MediaPlayer/MediaPlayer.h>

static void *MyStreamingMovieViewControllerTimedMetadataObserverContext = &MyStreamingMovieViewControllerTimedMetadataObserverContext;
static void *MyStreamingMovieViewControllerRateObservationContext = &MyStreamingMovieViewControllerRateObservationContext;
static void *MyStreamingMovieViewControllerCurrentItemObservationContext = &MyStreamingMovieViewControllerCurrentItemObservationContext;
static void *MyStreamingMovieViewControllerPlayerItemStatusObserverContext = &MyStreamingMovieViewControllerPlayerItemStatusObserverContext;

NSString *kTracksKey		= @"tracks";
NSString *kStatusKey		= @"status";
NSString *kRateKey			= @"rate";
NSString *kPlayableKey		= @"playable";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";

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
    
    NSTimer *liveViewSwitchTimer;
    NSTimer *liveViewDateStringUpdater;
    BOOL isPlayerStarted;
    
}

@property (nonatomic, retain) PhxSocket *socket;
@property (nonatomic, retain) PhxChannel *channel;

@end

@implementation CameraPlayViewController
@synthesize isCameraRemoved;
@synthesize playerLayerView;
@synthesize player, playerItem;

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
    [self setTitleBarAccordingToOrientation];
    runFirstTime            = YES;
    videoController.alpha   = 0.0;
    self.screenName         = @"Video View";
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    
    runFirstTime            = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self removeLiveViewObservers];
    [self.channel leave];
    [self.socket disconnect];
    self.channel = nil;
    self.socket = nil;
}

-(void)setTitleBarAccordingToOrientation{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        [self setNavigationBarAnimation:NO isPortrait:YES];
        
    } else {
        
        [self setNavigationBarAnimation:YES isPortrait:NO];
    }
}

-(void)setNavigationBarAnimation:(BOOL)isHide isPortrait:(BOOL)agree{
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
        
        [[UIApplication sharedApplication] setStatusBarHidden:agree?isHide:YES];
        
//        [playerLayerView setFrame:self.playerLayerView.bounds];
//        [self.streamPlayer.view setFrame:self.streamingView.bounds];
        
        self.titlebar.backgroundColor       = agree?[UIColor colorWithRed:52.0f/255.0f green:57.0/255.0f blue:61.0/255.0f alpha:1.0f]:[UIColor clearColor];
        
        if (isHide) {
            self.titlebar.frame             = CGRectMake(self.titlebar.frame.origin.x, -64, self.titlebar.frame.size.width, self.titlebar.frame.size.height);
            if (dropDown)
            {
                [dropDown hideDropDown:self.btnTitle];
                dropDown = nil;
            }
        }else{
            self.titlebar.frame             = CGRectMake(self.titlebar.frame.origin.x, 0, self.titlebar.frame.size.width, self.titlebar.frame.size.height);
        }
        
        self.hiddenDropDownBtn.hidden       = isHide;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setTitleBarAccordingToOrientation];
    
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    
    video_view.frame = CGRectMake(0, 0, self.playerView.frame.size.width,self.playerView.frame.size.height);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isCameraRemoved) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playCamera];
    [self disableSleep];
    
    long sleepTimerSecs = [PreferenceUtil getSleepTimerSecs];
    [self performSelector:@selector(enableSleep) withObject:nil afterDelay:sleepTimerSecs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self enableSleep];
}

- (void)disableSleep {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)enableSleep {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc {
    
    if (timeCounter && [timeCounter isValid])
    {
        [timeCounter invalidate];
        timeCounter = nil;
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
        
        CVPixelBufferRef buffer = [self.output copyPixelBufferForItemTime:playerItem.currentTime itemTimeForDisplay:nil];
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgiimage = [context createCGImage:[CIImage imageWithCVPixelBuffer:buffer] fromRect:[CIImage imageWithCVPixelBuffer:buffer].extent];
        UIImage *snapImg = [UIImage imageWithCGImage:cgiimage];
        CGImageRelease(cgiimage);
//        UIImage *snapImg = [[UIImage alloc] initWithCIImage:[CIImage imageWithCVPixelBuffer:buffer]];
        imvSnapshot.image = snapImg;

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
    ViewCameraViewController *viewCameraVC = [[ViewCameraViewController alloc] initWithNibName:@"ViewCameraViewController" bundle:[NSBundle mainBundle]];
    viewCameraVC.camera = self.cameraInfo;
    viewCameraVC.delegate = self;
    [self.navigationController presentViewController:viewCameraVC animated:YES completion:nil];
}

- (void)showSavedImages {
    if ([CommonUtil snapshotFiles:self.cameraInfo.camId].count == 0) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:@"No snapshot saved for this camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        
        return;
    }
    SnapshotViewController *snapshotVC = [[SnapshotViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"SnapshotViewController" : @"SnapshotViewController_iPad" bundle:[NSBundle mainBundle]];
    snapshotVC.cameraId = self.cameraInfo.camId;
    [self.navigationController presentViewController:snapshotVC animated:YES completion:nil];
    //KEEPING THIS  CODE FOR FUTURE REFERENCE
    /*
     CustomNavigationController *viewCamNavVC = [[CustomNavigationController alloc] initWithRootViewController:snapshotVC];
     viewCamNavVC.navigationBarHidden = YES;
     viewCamNavVC.isPortraitMode = YES;
     [self presentViewController:viewCamNavVC animated:YES completion:nil];
     */
}

- (void)viewRecordings {
    RecordingsViewController *recordingsVC = [[RecordingsViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ?@"RecordingsViewController":@"RecordingsViewController_iPad" bundle:[NSBundle mainBundle]];
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
    }
    else {
        [self showVideoController:YES];
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
        
        dropDown = [[NIDropDown alloc] showDropDown:self.hiddenDropDownBtn height:(h<=f?&h: &f) textArray:cameraNameArray imageArray:arrImage direction:@"down"] ;
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
}

- (IBAction)playOrPause:(id)sender {
    if (isPlaying) {
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_play.png"] forState:UIControlStateNormal];
        [self stopCamera];
    } else {
        [self showVideoController:NO];
        [playOrPauseButton setBackgroundImage:[UIImage imageNamed:@"btn_pause.png"] forState:UIControlStateNormal];
        [self playCamera];
    }
}
- (IBAction)handleSingleTap:(id)sender {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(orientation))
    {
        //LandscapeView
        if (self.titlebar.frame.origin.y == -64)
        {
            [self setNavigationBarAnimation:NO isPortrait:NO];
        }
        else
        {
            [self setNavigationBarAnimation:YES isPortrait:NO];
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
    [self takeSnapshot];
    [self hideSnapshotView];
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
        [sheet addButtonWithTitle:@"Cloud Recordings" block:^{
            [self viewRecordings];
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
                                         actionWithTitle:@"Cloud Recordings"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [view dismissViewControllerAnimated:YES completion:nil];
                                             [self viewRecordings];
                                             
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
    
    if (timeCounter && [timeCounter isValid])
    {
        [timeCounter invalidate];
        timeCounter = nil;
    }
    
    self.lblTimeCode.hidden     = YES;
    video_view.hidden           = YES;
    self.playerLayerView.hidden = YES;
    
    if ([self.cameraInfo isOnline]) {
        self.lblOffline.hidden = YES;
        [loadingView startAnimating];
        if (self.imageView)
        {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
        }
        
        if (self.cameraInfo.hlsUrl && self.cameraInfo.hlsUrl.length > 0) {
            isPlayerStarted = NO;
            NSURL *newMovieURL = [NSURL URLWithString:self.cameraInfo.hlsUrl];
            if ([newMovieURL scheme])
            {
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newMovieURL options:nil];
                
                NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];

                [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
                 ^{
                     dispatch_async( dispatch_get_main_queue(),
                                    ^{
                                        [self prepareToPlayAsset:asset withKeys:requestedKeys];
                                    });
                 }];
            }
            
            self.playerLayerView.hidden = NO;
            
        } else {
            [self setUpJPGView];            
        }
    } else {
        self.imageView.image = nil;
        [loadingView stopAnimating];
        self.lblOffline.hidden = NO;
    }
    isPlaying = YES;
}

-(void)setUpJPGView{
    self.lblTimeCode.hidden = NO;
    self.lblTimeCode.text   = @"";
    [self createBrowseView];
    [self phoenixConnect];
}

#pragma mark Player Notifications

- (void) playerItemDidReachEnd:(NSNotification*) aNotification
{
    [loadingView stopAnimating];
}
- (void) failedToPlayToEndTime:(NSNotification*) aNotification{
    NSLog(@"Failed To Play To end Time");
}

-(void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}


-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removeLiveViewObservers];
    [loadingView startAnimating];
    self.playerLayerView.hidden = YES;
    [self setUpJPGView];
}


- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
    }
    
    if (!asset.playable)
    {
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];

        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }

    if (self.playerItem)
    {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }

    NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    
    self.output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];

    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failedToPlayToEndTime:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:self.playerItem];
    
    if (![self player])
    {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];

        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerCurrentItemObservationContext];
        
        [self.player addObserver:self
                      forKeyPath:kTimedMetadataKey
                         options:0
                         context:MyStreamingMovieViewControllerTimedMetadataObserverContext];
        
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerRateObservationContext];
    }
    
    if (self.player.currentItem != self.playerItem)
    {
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
    }
    
    
}
-(void)switchToJpgView{
    [self removeLiveViewObservers];
    [loadingView stopAnimating];
    self.playerLayerView.hidden = YES;
    if (liveViewDateStringUpdater) {
        [liveViewDateStringUpdater invalidate];
        liveViewDateStringUpdater = nil;
    }
    [self setUpJPGView];
}

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    
    if (object == self.playerItem && [path isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.playerItem.playbackBufferEmpty) {
            NSLog(@"playbackBufferEmpty");
            [loadingView startAnimating];
            liveViewSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(switchToJpgView) userInfo:nil repeats:NO];
            return;
        }
    }
    
    else if (object == self.playerItem && [path isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.player.currentItem.playbackLikelyToKeepUp == NO &&
            CMTIME_COMPARE_INLINE(self.player.currentTime, >, kCMTimeZero) &&
            CMTIME_COMPARE_INLINE(self.player.currentTime, !=, self.player.currentItem.duration)) {
            NSLog(@"Player Hanging");
            return;
        }
        if (self.playerItem.playbackLikelyToKeepUp == YES)
        {
            NSLog(@"playbackLikelyToKeepUp");
            if (liveViewSwitchTimer) {
                [liveViewSwitchTimer invalidate];
                liveViewSwitchTimer = nil;
            }
            return;
        }
    }
    if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                [self removePlayerTimeObserver];
                [loadingView startAnimating];
                liveViewSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(switchToJpgView) userInfo:nil repeats:NO];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                playerLayerView.playerLayer.hidden = NO;

                playerLayerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];

                [playerLayerView.playerLayer setPlayer:player];
                if (liveViewDateStringUpdater) {
                    [liveViewDateStringUpdater invalidate];
                    liveViewDateStringUpdater   = nil;
                }
                liveViewDateStringUpdater = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setDateLabelForHLS) userInfo:nil repeats:YES];
                [loadingView stopAnimating];
                if (!isPlayerStarted) {
                    NSLog(@"START PLAYING");
                    isPlayerStarted = YES;
                    [self.playerItem addOutput:self.output];
                    [player play];
                }
                
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *thePlayerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:thePlayerItem.error];
            }
                break;
        }
    }

    else if (context == MyStreamingMovieViewControllerRateObservationContext)
    {
        
    }

    else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];

        if (newPlayerItem == (id)[NSNull null])
        {
            
        }
        else
        {
            [playerLayerView.playerLayer setPlayer:self.player];
            
            [playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            
        }
    }

    else if (context == MyStreamingMovieViewControllerTimedMetadataObserverContext)
    {
        NSArray* array = [[player currentItem] timedMetadata];
        for (AVMetadataItem *metadataItem in array)
        {
            //            [self handleTimedMetadata:metadataItem];
        }
    }
    else
    {
        //		[super observeValueForKeyPath:path ofObject:object change:change context:context];
    }
    
    return;
}


- (void)phoenixConnect {
    
    dispatch_queue_t myQueue = dispatch_queue_create("Phoenix Queue",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        if (self.socket != nil && [self.socket isConnected]) {
            return;
        }
        self.socket = [[PhxSocket alloc] initWithURL:[NSURL URLWithString:@"wss://media.evercam.io/socket/websocket"] heartbeatInterval:20];
        
        [self.socket connectWithParams:@{@"api_key":[APP_DELEGATE defaultUser].apiKey,@"api_id":[APP_DELEGATE defaultUser].apiId}];
        
        self.channel = [[PhxChannel alloc] initWithSocket:self.socket topic:[NSString stringWithFormat:@"cameras:%@",self.cameraInfo.camId] params:@{@"api_key":[APP_DELEGATE defaultUser].apiKey,@"api_id":[APP_DELEGATE defaultUser].apiId}];
        [self.channel onEvent:@"snapshot-taken" callback:^(id message, id ref) {
            [loadingView stopAnimating];
            UIImage *jpgImage =  [self decodeBase64ToImage:message[@"image"]];
            self.imageView.image = jpgImage;
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                [self performSelectorOnMainThread:@selector(setDateLabel:) withObject:message waitUntilDone:NO];
            });
            
        }];
        [self.channel join];
    });
    /*
    if (self.socket != nil && [self.socket isConnected]) {
        return;
    }
    self.socket = [[PhxSocket alloc] initWithURL:[NSURL URLWithString:@"wss://media.evercam.io/socket/websocket"] heartbeatInterval:20];
    
    [self.socket connectWithParams:@{@"api_key":[APP_DELEGATE defaultUser].apiKey,@"api_id":[APP_DELEGATE defaultUser].apiId}];
    
    self.channel = [[PhxChannel alloc] initWithSocket:self.socket topic:[NSString stringWithFormat:@"cameras:%@",self.cameraInfo.camId] params:@{@"api_key":[APP_DELEGATE defaultUser].apiKey,@"api_id":[APP_DELEGATE defaultUser].apiId}];
    
    [self.channel onEvent:@"snapshot-taken" callback:^(id message, id ref) {
        [loadingView stopAnimating];
        UIImage *jpgImage =  [self decodeBase64ToImage:message[@"image"]];
        self.imageView.image = jpgImage;
        [self performSelectorOnMainThread:@selector(setDateLabel:) withObject:message waitUntilDone:YES];
    }];
    [self.channel join];
    */
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(void)setDateLabel:(id)message{
    self.lblTimeCode.text           = [self getDateFromUnixFormat:[message[@"timestamp"] stringValue]];
}

-(void) setDateLabelForHLS{
    self.lblTimeCode.hidden         = NO;
    self.lblTimeCode.text           = [self getCameraTimeStringForHLS:[self getUTCDateString]];
}

- (NSString *) getDateFromUnixFormat:(NSString *)unixFormat
{
    NSTimeInterval serverTime       = [unixFormat doubleValue];
    
    NSDate *serverDate              = [NSDate dateWithTimeIntervalSince1970:serverTime];
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc] init];
    
    NSTimeZone *cameraTimeZone      = [NSTimeZone timeZoneWithName:self.cameraInfo.timezone];
    
    NSTimeInterval timeDifference   = [cameraTimeZone daylightSavingTimeOffsetForDate:serverDate];
    
    NSDate *correctDate             = [serverDate dateByAddingTimeInterval:timeDifference];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSString *dateString            = [dateFormatter stringFromDate:correctDate];
    
    return dateString;
    
}

- (NSString *) getUTCDateString{
    NSDateFormatter *dateformatter      = [[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    NSTimeZone *timeZone_UTC            = [NSTimeZone timeZoneWithName:@"UTC"];
    
    [dateformatter setTimeZone:timeZone_UTC];
    
    NSString *utcDateString             = [dateformatter stringFromDate:[NSDate date]];
    
    return utcDateString;
}

- (NSString *) getCameraTimeStringForHLS:(NSString *)utcDateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.cameraInfo.timezone]];
    
    //[formatter dateFromString:dateAsString]
    
    NSString *hlsCameraDateString  = [dateFormatter stringFromDate:[dateFormatter dateFromString:utcDateString]];
    
    return hlsCameraDateString;
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
        [self removeLiveViewObservers];
    
        if (timeCounter && [timeCounter isValid])
        {
            [timeCounter invalidate];
            timeCounter = nil;
        }
        self.lblTimeCode.hidden = YES;
        [self.channel leave];
        [self.socket disconnect];
    } else {
        return;
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
- (void)cameraDeletedSettings:(EvercamCamera *)camera {
    [self back:self];
    [self.delegate cameraDel:camera];
}


#pragma mark NIDropdown delegate
- (void) niDropDown:(NIDropDown*)dropdown didSelectAtIndex:(NSInteger)index {
    
    [self removeLiveViewObservers];
    
    dropDown = nil;
    [self.channel leave];
    [self.socket disconnect];
    self.channel = nil;
    self.socket = nil;
    
    self.cameraInfo = [self.cameras objectAtIndex:index];
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    [self playCamera];
    runFirstTime = YES;
}

-(void)removeLiveViewObservers{
    
    if (liveViewDateStringUpdater) {
        [liveViewDateStringUpdater invalidate];
        liveViewDateStringUpdater = nil;
    }
    
    [self.player pause];
    
    [self removePlayerTimeObserver];
    
    [self.playerItem removeObserver:self forKeyPath:kStatusKey];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];

    [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    [self.player removeObserver:self forKeyPath:kTimedMetadataKey];
    [self.player removeObserver:self forKeyPath:kRateKey];
    
    self.player = nil;
    
    self.playerItem = nil;
}

@end
