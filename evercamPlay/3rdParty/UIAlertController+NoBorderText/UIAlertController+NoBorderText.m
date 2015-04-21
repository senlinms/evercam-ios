//
//  UIAlertController+NoBorderText
//  Testplus
//
//  Created by Muhammad Ali Yousaf on 16/12/2014.
//  Copyright (c) 2014 Muhammad Ali Yousaf. All rights reserved.
//

#import "UIAlertController+NoBorderText.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIAlertController (NoBorderText)

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    for (UITextField *field in self.textFields)
    {
//        field.superview.backgroundColor = [UIColor clearColor];
//        CALayer *bottomBorder = [CALayer layer];
//        bottomBorder.frame = CGRectMake(0.0f, field.superview.frame.size.height - 1, field.superview.frame.size.width, 1.0f);
//        bottomBorder.backgroundColor = [UIColor grayColor].CGColor;//[UIColor colorWithRed:220.0/255.0 green:76.0/255.0 blue:63.0/255.0 alpha:1.0].CGColor;
//        [field.superview.layer addSublayer:bottomBorder];
        
    }
}
@end
