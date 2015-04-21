//
//  SelectVendorViewController.h
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EvercamVendor.h"

@protocol SelectVendorViewControllerDelegate <NSObject>

- (void)vendorChanged:(EvercamVendor *)vendor;

@end

@interface SelectVendorViewController : UIViewController

@property (nonatomic, strong) NSArray *vendorsArray;
@property (nonatomic, strong) EvercamVendor *selectedVendor;
@property (nonatomic, strong) id<SelectVendorViewControllerDelegate> delegate;

@end
