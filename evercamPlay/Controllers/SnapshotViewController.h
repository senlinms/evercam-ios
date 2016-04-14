//
//  SnapshotViewController.h
//  evercamPlay
//
//  Created by jw on 4/16/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnapshotViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) NSString *cameraId;
@property (weak, nonatomic) IBOutlet UILabel *imageNo;
@end
