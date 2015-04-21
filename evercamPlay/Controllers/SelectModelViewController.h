//
//  SelectVendorViewController.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamVendor.h"
#import "EvercamModel.h"

@protocol SelectModelViewControllerDelegate <NSObject>

- (void)modelChanged:(EvercamModel *)model;

@end

@interface SelectModelViewController : UIViewController

@property (nonatomic, strong) NSArray *modelsArray;
@property (nonatomic, strong) EvercamVendor *selectedVendor;
@property (nonatomic, strong) EvercamModel *selectedModel;
@property (nonatomic, strong) id<SelectModelViewControllerDelegate> delegate;

@end
