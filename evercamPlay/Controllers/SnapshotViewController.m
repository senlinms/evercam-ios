//
//  SnapshotViewController.m
//  evercamPlay
//
//  Created by jw on 4/16/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "SnapshotViewController.h"
#import "AppDelegate.h"
#import "CommonUtil.h"
#import "BlockActionSheet.h"
#import "GlobalSettings.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SnapshotViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation SnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (void)exportSavedImg
{
    NSInteger activeIdx = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
    if (activeIdx >= snapshotFiles.count) {
        return;
    }
    
    NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:activeIdx];
    UIImage *snapshotImg = [UIImage imageWithContentsOfFile:snapshotFileURL.path];
    UIImageWriteToSavedPhotosAlbum(snapshotImg, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)deleteSavedImg
{
    NSInteger activeIdx = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
    if (activeIdx >= snapshotFiles.count) {
        return;
    }
    
    NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:activeIdx];
    
    NSString *filePath = [snapshotFileURL path];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] == NO) {
        UIAlertView *simpleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [simpleAlert show];
        return;
    }
    
    if (error == nil) {
        [self loadImages];
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }
}

- (void)loadImages {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
    if (snapshotFiles.count <= 0) {
        [_actionBtn setEnabled:NO];
    }
    
    for (NSInteger i = 0; i < snapshotFiles.count; i++) {
        NSURL *snapshotFileURL = [snapshotFiles objectAtIndex:i];
        UIImageView *snapshotImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:snapshotFileURL.path]];
        snapshotImgView.contentMode = UIViewContentModeScaleAspectFit;
        snapshotImgView.frame = CGRectMake(i * screenSize.width, 0, screenSize.width, screenSize.height - 72);
        [self.scrollView addSubview:snapshotImgView];
    }
    
    [self.scrollView setContentSize:CGSizeMake(snapshotFiles.count * screenSize.width, 0)];
}

@end
