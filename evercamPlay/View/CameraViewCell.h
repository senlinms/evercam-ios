//
//  CameraViewCell.h
//  evercamPlay
//
//  Created by jw on 3/31/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface CameraViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet AsyncImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imvOffline;

@end
