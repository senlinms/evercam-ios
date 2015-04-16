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

@interface SnapshotViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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

- (void)loadImages {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    NSArray *snapshotFiles = [CommonUtil snapshotFiles:self.cameraId];
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
