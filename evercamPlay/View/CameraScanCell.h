//
//  CameraScanCell.h
//  evercamPlay
//
//  Created by Zulqarnain on 6/1/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraScanCell : UITableViewCell{
    
}
@property (weak, nonatomic) IBOutlet UILabel *camera_Name_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *ip_Address_Lbl;
@property (weak, nonatomic) IBOutlet UILabel *detail_Lbl;
@property (weak, nonatomic) IBOutlet UIImageView *camera_Thumb_ImageView;

@end
