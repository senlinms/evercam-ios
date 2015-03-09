//
//  AccountCell.h
//  evercamPlay
//
//  Created by jw on 3/9/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *imgAvatar;
@property (nonatomic, strong) IBOutlet UILabel *lblName;
@property (nonatomic, strong) IBOutlet UILabel *lblEmail;
@end
