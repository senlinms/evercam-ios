
//
//  CameraPlayViewController.m
//  EvercamPlay
//
//  Created by jw on 4/9/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "CameraPlayViewController.h"
#import "EvercamShell.h"
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
#import "ShareViewController.h"
#import "EvercamUtility.h"
#import "EvercamPtzControls.h"
#import "EvercamCameraModelInfo.h"
#import "EvercamRefreshCamera.h"
#import "PresetListViewController.h"
@import Firebase;

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
    int media_width;
    int media_height;
    Boolean dragging_slider;
    BrowseJpgTask *browseJpgTask;
    BOOL isPlaying;
    NIDropDown *dropDown;
    NSTimer *timeCounter;
    NSString* currentImage;
    BOOL runFirstTime;
    __weak IBOutlet UIButton                *playOrPauseButton;
    __weak IBOutlet UIView                  *videoController;
    __weak IBOutlet UIButton                *saveButton;
    
    __weak IBOutlet UIView                  *snapshotConfirmView;
    __weak IBOutlet UIImageView             *imvSnapshot;
    __weak IBOutlet UIActivityIndicatorView *loadingView;
    
    NSTimer *liveViewSwitchTimer;
    NSTimer *liveViewDateStringUpdater;
    BOOL isPlayerStarted;
    
    UITapGestureRecognizer *ptzViewTap;
}

@property (nonatomic, retain) PhxSocket *socket;
@property (nonatomic, retain) PhxChannel *channel;

@end

@implementation CameraPlayViewController
@synthesize isCameraRemoved;
@synthesize playerLayerView;
@synthesize player, playerItem;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    runFirstTime            = YES;
    videoController.alpha   = 0.0;
    self.screenName         = @"Video View";
    


    [self changeBtnTitle];
    runFirstTime            = NO;
    
    ptzViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    ptzViewTap.numberOfTouchesRequired = 1;
    [self.ptc_Control_View addGestureRecognizer:ptzViewTap];
    [self.playerLayerView addGestureRecognizer:ptzViewTap];
    [self.playerView addGestureRecognizer:ptzViewTap];
    
    self.liveViewScroll.minimumZoomScale=1;
    self.liveViewScroll.maximumZoomScale=5;
    self.liveViewScroll.delegate=self;
    
    
//    self.liveViewScroll.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    CGSize widthOne = [string sizeWithAttributes:attributes];
    CGFloat width = [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
    return width + 20;
}

-(void)changeBtnTitle{
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
        [self.btnTitle setFrame:CGRectMake(self.btnTitle.frame.origin.x, self.btnTitle.frame.origin.y, [self widthOfString:self.cameraInfo.name withFont:[UIFont fontWithName:@"Arial" size:16]], self.btnTitle.frame.size.height)];
        self.downImgView.frame = CGRectMake(self.btnTitle.frame.origin.x + self.btnTitle.frame.size.width + 10, self.downImgView.frame.origin.y, self.downImgView.frame.size.width, self.downImgView.frame.size.height);
    }];
    
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
        
        [self setPtzControlButtons];
        
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
    if (self.playerLayerView.hidden) {
        self.liveViewScroll.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
    }else{
        self.liveViewScroll.contentSize = CGSizeMake(self.playerLayerView.frame.size.width, self.playerLayerView.frame.size.height);
    }
    CGFloat newContentOffsetX = (self.liveViewScroll.contentSize.width - self.liveViewScroll.frame.size.width) / 2;
    CGFloat newContentOffsetY = (self.liveViewScroll.contentSize.height - self.liveViewScroll.frame.size.height) / 2;
    self.liveViewScroll.contentOffset = CGPointMake(newContentOffsetX, newContentOffsetY);
    
    [self setTitleBarAccordingToOrientation];
    
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    
    video_view.frame = CGRectMake(0, 0, self.playerView.frame.size.width,self.playerView.frame.size.height);
}

-(void)setPtzControlButtons{
    self.presetBtn.frame = CGRectMake(self.homeBtn.frame.origin.x-70-self.presetBtn.frame.size.width, self.presetBtn.frame.origin.y, self.presetBtn.frame.size.width, self.presetBtn.frame.size.height);
    self.leftBtn.frame = CGRectMake(self.homeBtn.frame.origin.x-10-self.leftBtn.frame.size.width, self.leftBtn.frame.origin.y, self.leftBtn.frame.size.width, self.leftBtn.frame.size.height);
    self.rightBtn.frame = CGRectMake(self.homeBtn.frame.origin.x+self.homeBtn.frame.size.width+10, self.rightBtn.frame.origin.y, self.rightBtn.frame.size.width, self.rightBtn.frame.size.height);
    self.zoomInBtn.frame = CGRectMake(self.homeBtn.frame.origin.x+self.homeBtn.frame.size.width+70, self.zoomInBtn.frame.origin.y, self.zoomInBtn.frame.size.width, self.zoomInBtn.frame.size.height);
    self.zoomOutBtn.frame = CGRectMake(self.homeBtn.frame.origin.x+self.homeBtn.frame.size.width+70, self.zoomOutBtn.frame.origin.y, self.zoomOutBtn.frame.size.width, self.zoomOutBtn.frame.size.height);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (isCameraRemoved) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    if (AppUtility.isFullyDismiss) {
        AppUtility.isFullyDismiss = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCameraModelInformation];
    [self setTitleBarAccordingToOrientation];
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

-(void)getCameraModelInformation{
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cameraInfo.model_id,@"model_id",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    EvercamCameraModelInfo *api_cam_Object = [EvercamCameraModelInfo new];
    [api_cam_Object getCameraModelInformation:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSArray *modelDetailsArray  = details[@"models"];
            NSDictionary *modelInfo     = modelDetailsArray[0];
            
            if ([modelInfo[@"ptz"] boolValue] && [self.cameraInfo.rights.rightsString rangeOfString:@"edit" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                //show PTZ control here
                self.ptc_Control_View.hidden = NO;
            }else{
                self.ptc_Control_View.hidden = YES;
            }
        }else{
            //failed to get camera model info hide PTZ controls
            self.ptc_Control_View.hidden = YES;
        }
    }];
    
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

- (void)showShareView{
    ShareViewController *sVc    = [[ShareViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"ShareViewController":@"ShareViewController_iPad" bundle:[NSBundle mainBundle]];
    sVc.camera_Object           = self.cameraInfo;
    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:sVc];
    navVC.isPortraitMode        = YES;
    [navVC setHasLandscapeMode:YES];
    navVC.navigationBarHidden   = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

- (void)showCameraView {
    ViewCameraViewController *viewCameraVC = [[ViewCameraViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ?@"ViewCameraViewController":@"ViewCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    viewCameraVC.camera = self.cameraInfo;
    viewCameraVC.delegate = self;
    CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:viewCameraVC];
    navVC.isPortraitMode        = YES;
    [navVC setHasLandscapeMode:YES];
    navVC.navigationBarHidden   = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
//    [self.navigationController presentViewController:viewCameraVC animated:YES completion:nil];
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
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"button Index: %ld",(long)buttonIndex);
    switch (buttonIndex) {
        case 0:{
            [self showCameraView];
        }
            
            break;
        case 1:{
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Share"]) {
                [self showShareView];
            }else{
             [self showSavedImages];   
            }
        }
            
            break;
        case 2:{
            if (actionSheet.tag == 5608) {
                [self showSavedImages];
            }else{
                [self viewRecordings];
            }
            
        }
            
            break;
        case 3:{
            if (actionSheet.tag == 5608) {
                [self viewRecordings];
            }
        }
            
            break;
            
        default:
            break;
    }
}

- (IBAction)action:(id)sender {
    if ([GlobalSettings sharedInstance].isPhone)
    {
        UIActionSheet *sheet;
        if ([self.cameraInfo.rights.rightsString rangeOfString:@"edit" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Settings",@"Share",@"Saved Images",@"Cloud Recordings", nil];
            sheet.tag = 5608;
        }else{
            sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Settings",@"Saved Images",@"Cloud Recordings", nil];
        }
        [sheet showInView:self.view];
    }
    else
    {
        [self presentPopOverForiPad:sender];
    }
}

-(void)presentPopOverForiPad:(id)sender{
    UIAlertController * popOverView=   [UIAlertController
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
                                      [popOverView dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
    
    UIAlertAction* viewRecordings = [UIAlertAction
                                     actionWithTitle:@"Cloud Recordings"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [popOverView dismissViewControllerAnimated:YES completion:nil];
                                         [self viewRecordings];
                                         
                                     }];
    
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [popOverView dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [popOverView addAction:viewDetails];
    if ([self.cameraInfo.rights.rightsString rangeOfString:@"edit" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        UIAlertAction* shareView = [UIAlertAction
                                    actionWithTitle:@"Share"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self showShareView];
                                        
                                    }];
        [popOverView addAction:shareView];
    }
    [popOverView addAction:savedImages];
    [popOverView addAction:viewRecordings];
    [popOverView addAction:cancel];
    
    
    UIPopoverPresentationController *popPresenter = [popOverView
                                                         popoverPresentationController];
    popPresenter.sourceView = (UIView *)sender;
    popPresenter.sourceRect = ((UIView *)sender).bounds;
    [self presentViewController:popOverView animated:YES completion:nil];
    

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
        self.refreshBtn.hidden = YES;
        [loadingView startAnimating];
        
        if (self.imageView)
        {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
        }
        
        if (self.cameraInfo.hlsUrl && self.cameraInfo.hlsUrl.length > 0) {
            
            isPlayerStarted = NO;
            
            NSURL *newMovieURL;
            
            newMovieURL = [NSURL URLWithString:self.cameraInfo.hlsUrl];
            
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
            
            [self.liveViewScroll setContentSize:CGSizeMake(self.playerLayerView.frame.size.width, self.playerLayerView.frame.size.height)];
            
        } else {
            [self setUpJPGView];
        }
    } else {
        self.imageView.image = nil;
        [loadingView stopAnimating];
        self.lblOffline.hidden = NO;
        self.refreshBtn.hidden = NO;
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
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"api.evercam.io" code:0 userInfo:errorDict];
        
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
                    
                    [FIRAnalytics logEventWithName:@"RTSP_Streaming"
                                        parameters:@{
                                                     @"RTSP_Stream_Played": @"Successfully played RTSP stream."
                                                     }];
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
        
        [FIRAnalytics logEventWithName:@"JPG_Streaming"
                            parameters:@{
                                         @"JPG_Stream_Played": @"Successfully played JPG stream."
                                         }];
                
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
    self.imageView.userInteractionEnabled = YES;
    [self.liveViewScroll addSubview:self.imageView];
    [self.liveViewScroll sendSubviewToBack:self.imageView];
    [self.imageView addGestureRecognizer:self.pinchGesture_outlet];
    [self.imageView addGestureRecognizer:ptzViewTap];
    [self.liveViewScroll setContentSize:CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height)];
//    [self.playerView addSubview:self.imageView];
//    [self.playerView sendSubviewToBack:self.imageView];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timeCounter && [timeCounter isValid])
        {
            [timeCounter invalidate];
            timeCounter = nil;
        }
        timeCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateTimeCode) userInfo:nil repeats:YES];
    });
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
    [self changeBtnTitle];
//    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
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
    [self changeBtnTitle];
//    [self.btnTitle setTitle:self.cameraInfo.name forState:UIControlStateNormal];
    self.ptc_Control_View.hidden = YES;
    [self getCameraModelInformation];
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

- (IBAction)ptz_Controls_Action:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (btn.tag == 0) {
        //home
        [self setCameraToHome];
    }else if (btn.tag == 1){
        //up
        [self setCameraDirection:@"up=4"];
    }else if (btn.tag == 2){
        //down
        [self setCameraDirection:@"down=4"];
    }else if (btn.tag == 3){
        //left
        [self setCameraDirection:@"left=4"];
    }else if (btn.tag == 4){
        //right
        [self setCameraDirection:@"right=4"];
    }else if (btn.tag == 5){
        //preset
        PresetListViewController *sVc    = [[PresetListViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"PresetListViewController":@"PresetListViewController_iPad" bundle:[NSBundle mainBundle]];
        sVc.cameraID           = self.cameraInfo.camId;
        CustomNavigationController *navVC = [[CustomNavigationController alloc] initWithRootViewController:sVc];
        navVC.isPortraitMode        = YES;
        [navVC setHasLandscapeMode:YES];
        navVC.navigationBarHidden   = YES;
        [self.navigationController presentViewController:navVC animated:YES completion:nil];
    }else if (btn.tag == 6){
        //zoom in
        [self setCameraDirection:@"zoom=1"];
    }else if (btn.tag == 7){
        //zoom out
        [self setCameraDirection:@"zoom=-1"];
    }
}

- (IBAction)dropDownImg_Tapped:(id)sender {
    [self cameraItemTapped:self.btnTitle];
}

-(void)setCameraToHome{

    NSDictionary * param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cameraInfo.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    EvercamPtzControls *ptz_Object = [EvercamPtzControls new];
    [ptz_Object ptz_Home:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"Successfully set to Home");
        }else{
            NSLog(@"Error setting to home: %@",error.localizedDescription);
        }
    }];
    
}

-(void)setCameraDirection:(NSString *)direction{
    NSDictionary * param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cameraInfo.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key",direction,@"camera_Direction", nil];
    EvercamPtzControls *ptz_Object = [EvercamPtzControls new];
    [ptz_Object set_CameraDirection:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"Successfully set the direction");
        }else{
            NSLog(@"Error: %@",error.localizedDescription);
        }
    }];
}


- (IBAction)pinchGestureAction:(id)sender {
    if ([loadingView isAnimating]) {
        return;
    }
    UIPinchGestureRecognizer *recognizer = (UIPinchGestureRecognizer *)sender;
    CGFloat currentScale = recognizer.view.frame.size.width / recognizer.view.bounds.size.width;
    CGFloat newScale = currentScale * recognizer.scale;
    if (newScale <= 1) {
//        NSLog(@"scale is 1 or less");
        newScale = 1;
    }
    if (newScale >= 5) {
        newScale = 5;
    }
    
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
    
    [self.liveViewScroll zoomToRect:zoomRect animated:YES];
    
    if (zoomRect.size.width == self.view.frame.size.width || zoomRect.size.height == self.view.frame.size.height) {
        if (self.playerLayerView.hidden){
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.x,self.view.frame.size.width, self.view.frame.size.height);
            self.liveViewScroll.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
        }else{
            self.playerLayerView.frame = CGRectMake(self.playerLayerView.frame.origin.x, self.playerLayerView.frame.origin.x,self.view.frame.size.width, self.view.frame.size.height);
            self.liveViewScroll.contentSize = CGSizeMake(self.playerLayerView.frame.size.width, self.playerLayerView.frame.size.height);
        }

        CGFloat newContentOffsetX = (self.liveViewScroll.contentSize.width - self.liveViewScroll.frame.size.width) / 2;
        CGFloat newContentOffsetY = (self.liveViewScroll.contentSize.height - self.liveViewScroll.frame.size.height) / 2;
        self.liveViewScroll.contentOffset = CGPointMake(newContentOffsetX, newContentOffsetY);
    }
    
}
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView {
  
        CGFloat offsetX = (self.liveViewScroll.bounds.size.width > self.liveViewScroll.contentSize.width)?
        (self.liveViewScroll.bounds.size.width - self.liveViewScroll.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (self.liveViewScroll.bounds.size.height > self.liveViewScroll.contentSize.height)?
        (self.liveViewScroll.bounds.size.height - self.liveViewScroll.contentSize.height) * 0.5 : 0.0;
        if (self.playerLayerView.hidden) {
            
            if (self.imageView.frame.size.width < self.view.frame.size.width || self.imageView.frame.size.height < self.view.frame.size.height) {
                self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }else{
                self.imageView.center = CGPointMake(self.liveViewScroll.contentSize.width * 0.5 + offsetX,
                                                    self.liveViewScroll.contentSize.height * 0.5 + offsetY);
            }
        }else{
            
            if (self.playerLayerView.frame.size.width < self.view.frame.size.width ) {
                self.playerLayerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
            }else{
                self.playerLayerView.center = CGPointMake(self.liveViewScroll.contentSize.width * 0.5 + offsetX,
                                                          self.liveViewScroll.contentSize.height * 0.5 + offsetY);
            }
        }
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (self.playerLayerView.hidden) {
        return self.imageView;
    }else{
        return self.playerLayerView;
    }
    return nil;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.liveViewScroll frame].size.height / scale;
    zoomRect.size.width  = [self.liveViewScroll frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


- (IBAction)refreshAction:(id)sender {
    NSLog(@"Call Refresh");
    [MBProgressHUD showHUDAddedTo:MainWindow animated:YES];
    EvercamRefreshCamera *refreshObj = [[EvercamRefreshCamera alloc] init];
    
    NSDictionary * param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cameraInfo.camId,@"camId",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    
    [refreshObj refreshOfflineCamera:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            [MBProgressHUD hideHUDForView:MainWindow animated:YES];
            NSLog(@"Successfully refresh the camera");
        }else{
            [MBProgressHUD hideHUDForView:MainWindow animated:YES];
            [AppUtility displayAlertWithTitle:@"Error!" AndMessage:error.localizedDescription];
            NSLog(@"Error: %@",error.localizedDescription);
        }
    }];
}
@end
