//
//  SnapshotViewController.m
//  evercamPlay
//
//  Created by jw on 4/16/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "SnapshotViewController.h"
#import "AppDelegate.h"
#import "CommonUtil.h"
#import "BlockActionSheet.h"
#import "GlobalSettings.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define TAG_CONTENT_IMAGES 100

@interface SnapshotViewController ()
{
    int imagesCount;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (assign, nonatomic) NSInteger pageIndex;

@end

@implementation SnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageIndex = 0;

    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self loadImages];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Changing scrollview size
    self.scrollView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);//self.view.bounds;

    // And size of all images
    NSArray *subviews = self.scrollView.subviews;
    NSArray<UIImageView *> *images = [subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.tag == %d", TAG_CONTENT_IMAGES]];
    for (int i = 0; i < images.count; i++) {
        images[i].frame = CGRectMake(i * self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    }
    
    // Recalculating content size and visible image (content offset)
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * images.count, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(self.pageIndex * self.scrollView.bounds.size.width, 0);

    // We also need to recalculate label position
    CGRect newImageNoFrame = self.imageNo.frame;
    newImageNoFrame.origin = CGPointMake(
        (self.scrollView.bounds.size.width - self.imageNo.bounds.size.width) / 2,
        self.view.bounds.size.height - self.imageNo.bounds.size.height * 2
    );
    self.imageNo.frame = newImageNoFrame;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onAction:(id)sender {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
        
        [sheet addButtonWithTitle:@"Export" block:^{
            [self exportSavedImg];
        }];
        [sheet addButtonWithTitle:@"Delete" block:^{
            [self deleteSavedImg];
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
        
        UIAlertAction* exportAction = [UIAlertAction
                                      actionWithTitle:@"Export"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [self exportSavedImg];
                                          
                                      }];
        UIAlertAction* removeAction = [UIAlertAction
                                       actionWithTitle:@"Delete"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           [view dismissViewControllerAnimated:YES completion:nil];
                                           [self deleteSavedImg];
                                           
                                       }];
        
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [view addAction:exportAction];
        [view addAction:removeAction];
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return;
    }
    else
    {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Export Image", nil) message:@"The image was exported to your photo album successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return;
    }
}

- (IBAction)exportSavedImg
{
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
    NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:self.pageIndex];
    UIImage *snapshotImg = [UIImage imageWithContentsOfFile:snapshotFileURL.path];
    UIImageWriteToSavedPhotosAlbum(snapshotImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101 && buttonIndex == 1)
    {
        NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
        NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:self.pageIndex];
        NSString *filePath = [snapshotFileURL path];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] == NO) {
            UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [simpleAlert show];
            return;
        }
        
        if (error == nil) {
            if (snapshotFiles.count == 1) {
                [self back:nil];
                return;
            }
            // Checking if we deleted last image
            if(self.pageIndex >= snapshotFiles.count - 2) { // -1 - pageIndex starts from 0 and -1 - we have deleted one image already
                self.pageIndex = snapshotFiles.count  - 2;
            }
            [self loadImages];
        }
    }
}

- (IBAction)deleteSavedImg
{
    UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete snapshot", nil) message:@"Are you sure you want to delete this image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
    simpleAlert.tag = 101;
    [simpleAlert show];
}

- (void)loadImages {
    // Clear scrollview context
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
    imagesCount = (int)snapshotFiles.count;
    if (snapshotFiles.count <= 0) {
        [_actionBtn setEnabled:NO];
    }
    else{
        self.imageNo.text = [NSString stringWithFormat:@"%ld / %d" , (long)self.pageIndex + 1, imagesCount];
    }
    
    for (NSInteger i = 0; i < snapshotFiles.count; i++) {
        NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:i];
        UIImageView *snapshotImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:snapshotFileURL.path]];
        snapshotImgView.contentMode = UIViewContentModeScaleAspectFit;
        snapshotImgView.tag = TAG_CONTENT_IMAGES;
        [self.scrollView addSubview:snapshotImgView];
    }
    
    [self.view setNeedsLayout];
}

-(void)scrollViewDidEndDecelerating:(nonnull UIScrollView *)scrollView
{
    self.pageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.imageNo.text = [NSString stringWithFormat:@"%ld / %d", (self.pageIndex+1) , imagesCount];
}

@end
