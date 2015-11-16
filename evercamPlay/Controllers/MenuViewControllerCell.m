//
//  MenuViewControllerCell.m
//  evercamPlay
//
//  Created by Ahmad  Hassan on 10/11/2015.
//  Copyright © 2015 evercom. All rights reserved.
//

#import "MenuViewControllerCell.h"

@implementation MenuViewControllerCell


- (void) layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(self.imageView.frame.size.width + 50, 0, 150, self.frame.size.height);
    
//    CGRect rect = self.imageView.frame;
//    rect.size.width = 30;
//    rect.size.height = 30;
//    self.imageView.frame = rect;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
