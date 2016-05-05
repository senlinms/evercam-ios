
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
    
}

@property (nonatomic, retain) PhxSocket *socket;
@property (nonatomic, retain) PhxChannel *channel;

@property (strong, nonatomic) MPMoviePlayerController *streamPlayer;
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
        
        [self.streamPlayer.view setFrame:self.streamingView.bounds];
        
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

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (void)showSnapshotView {
    [snapshotConfirmView setHidden:NO];
    
    if (self.imageView == nil || self.imageView.hidden == YES) {
        
        CVPixelBufferRef buffer = [self.output copyPixelBufferForItemTime:playerItem.currentTime itemTimeForDisplay:nil];
        //    [CIImage imageWithCVPixelBuffer:buffer];
        UIImage *snapImg = [[UIImage alloc] initWithCIImage:[CIImage imageWithCVPixelBuffer:buffer]];
        
//        UIImage *imgae = [self imageWithView:self.view];
        imvSnapshot.image = snapImg;
        
        /*
         CGRect rect = [self.streamingView bounds];
         UIGraphicsBeginImageContext(rect.size);
         CGContextRef context = UIGraphicsGetCurrentContext();
         [self.streamingView.layer renderInContext:context];
         UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         */
        /*
         CGRect rect = [self.streamingView bounds];
         UIGraphicsBeginImageContext(rect.size);
         
         if ([self.streamingView drawViewHierarchyInRect:rect afterScreenUpdates:YES]) {
         NSLog(@"Hierarchy drawn");
         }
         [self.streamingView drawViewHierarchyInRect:rect afterScreenUpdates:YES];
         UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         NSLog(@"streamingVideoSize: %@",NSStringFromCGSize(self.streamPlayer.naturalSize));
         rect.origin.y = (rect.size.height - rect.size.width*self.streamPlayer.naturalSize.height/self.streamPlayer.naturalSize.width)/2;
         //        rect.origin.y = (rect.size.height - rect.size.width*media_height/media_width)/2;
         rect.size.height = rect.size.width*self.streamPlayer.naturalSize.height/self.streamPlayer.naturalSize.width;
         CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], rect);
         // or use the UIImage wherever you like
         [imvSnapshot setImage:[UIImage imageWithCGImage:imageRef]];
         CGImageRelease(imageRef);
         */
        //        imvSnapshot.image = thumbnail;
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
        
        if (self.cameraInfo.hlsUrl && self.cameraInfo.hlsUrl.length > 0) {
            NSURL *newMovieURL = [NSURL URLWithString:self.cameraInfo.hlsUrl];
            if ([newMovieURL scheme])	/* Sanity check on the URL. */
            {
                /*
                 Create an asset for inspection of a resource referenced by a given URL.
                 Load the values for the asset keys "tracks", "playable".
                 */
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newMovieURL options:nil];
                
                NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
                
                /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
                [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
                 ^{
                     dispatch_async( dispatch_get_main_queue(),
                                    ^{
                                        /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
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

/* Called when the player item has played to its end time. */
- (void) playerItemDidReachEnd:(NSNotification*) aNotification
{
    [loadingView stopAnimating];
    /* Hide the 'Pause' button, show the 'Play' button in the slider control */
    
    
    /* After the movie has played to its end time, seek back to time zero
     to play it again */
    
}
- (void) failedToPlayToEndTime:(NSNotification*) aNotification{
    NSLog(@"Failed To Play To end Time");
}
/* Cancels the previously registered time observer. */
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
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing the use of -[AVAsset cancelLoading], add your code here to bail
         out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    self.output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    [self.playerItem addOutput:self.output];
    
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerPlayerItemStatusObserverContext];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failedToPlayToEndTime:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:self.playerItem];
    
    
    
    
    /* Create new player, if we don't already have one. */
    if (![self player])
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerCurrentItemObservationContext];
        
        /* A 'currentItem.timedMetadata' property observer to parse the media stream timed metadata. */
        [self.player addObserver:self
                      forKeyPath:kTimedMetadataKey
                         options:0
                         context:MyStreamingMovieViewControllerTimedMetadataObserverContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:MyStreamingMovieViewControllerRateObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
        
        
    }
    
    
}
-(void)switchToJpgView{
    [self removeLiveViewObservers];
    [loadingView stopAnimating];
    self.playerLayerView.hidden = YES;
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
            //Your code here
            NSLog(@"playbackBufferEmpty");
            [loadingView startAnimating];
            liveViewSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(switchToJpgView) userInfo:nil repeats:NO];
//            return;
        }
    }
    
    else if (object == self.playerItem && [path isEqualToString:@"playbackLikelyToKeepUp"])
    {
        if (self.player.currentItem.playbackLikelyToKeepUp == NO &&
            CMTIME_COMPARE_INLINE(self.player.currentTime, >, kCMTimeZero) &&
            CMTIME_COMPARE_INLINE(self.player.currentTime, !=, self.player.currentItem.duration)) {
            
            // if so, post the playerHanging notification
            NSLog(@"Player Hanging");
            [self.playerItem removeOutput:self.output];
//            return;
        }
        if (self.playerItem.playbackLikelyToKeepUp == YES)
        {
            //Your code here
            NSLog(@"playbackLikelyToKeepUp");
            if (liveViewSwitchTimer) {
                [liveViewSwitchTimer invalidate];
                liveViewSwitchTimer = nil;
            }
            [loadingView stopAnimating];
            [self.playerItem addOutput:self.output];
            [player play];
//            return;
        }
    }
    /* AVPlayerItem "status" property value observer. */
    if (context == MyStreamingMovieViewControllerPlayerItemStatusObserverContext)
    {
        
        
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                [self removePlayerTimeObserver];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                NSLog(@"AVPlayerStatusUnknown");
                playerLayerView.playerLayer.hidden = NO;
                
                
                
                /* Show the movie slider control since the movie is now ready to play. */
                
                
                
                playerLayerView.playerLayer.backgroundColor = [[UIColor blackColor] CGColor];
                
                /* Set the AVPlayerLayer on the view to allow the AVPlayer object to display
                 its content. */
                [playerLayerView.playerLayer setPlayer:player];
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
    /* AVPlayer "rate" property value observer. */
    else if (context == MyStreamingMovieViewControllerRateObservationContext)
    {
        
    }
    /* AVPlayer "currentItem" property observer.
     Called when the AVPlayer replaceCurrentItemWithPlayerItem:
     replacement will/did occur. */
    else if (context == MyStreamingMovieViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* New player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
            
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [playerLayerView.playerLayer setPlayer:self.player];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [playerLayerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            
        }
    }
    /* Observe the AVPlayer "currentItem.timedMetadata" property to parse the media stream
     timed metadata. */
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
    
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(void)setDateLabel:(id)message{
    self.lblTimeCode.text           = [self getDateFromUnixFormat:[message[@"timestamp"] stringValue]];
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

- (void)createPlayer {
    GstLaunchRemoteAppContext ctx;
    ctx.app                     = (__bridge gpointer)(self);
    ctx.initialized             = initialized_proxy;
    ctx.media_size_changed      = media_size_changed_proxy;
    ctx.set_current_position    = set_current_position_proxy;
    ctx.set_message             = set_message_proxy;
    
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
    
    self.cameraInfo = [self.cameras objectAtIndex:index];
    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    [self playCamera];
    runFirstTime = YES;
}

-(void)removeLiveViewObservers{
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
