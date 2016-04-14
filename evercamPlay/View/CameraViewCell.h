//
//  CameraViewCell.h
//  EvercamPlay
//
//  Created by jw on 3/31/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface CameraViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imvOffline;
@property (weak, nonatomic) IBOutlet UIView *greyImv;
@property (weak, nonatomic) IBOutlet UIView *secondaryView;

@end
