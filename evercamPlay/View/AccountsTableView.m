//
//  AccountsTableView.m
//  evercamPlay
//
//  Created by Zulqarnain on 9/5/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "AccountsTableView.h"
#import "AccountsTableViewCell.h"
#import "MenuViewControllerCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface AccountsTableView(){
    
}

@end

@implementation AccountsTableView
@synthesize AccountTableDelegate,accountsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        NSLog(@"table is load from xib");
        self.dataSource = self;
        self.delegate   = self;
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return accountsArray.count + 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    AccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AccountsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.row == accountsArray.count+1)
    {
        cell.email_Lbl.text                 = @"Manage accounts";
        cell.account_ImageView.image        = [UIImage imageNamed:@"ic_settings.png"];
        cell.account_ImageView.contentMode  = UIViewContentModeScaleAspectFit;
        
    }else if (indexPath.row == accountsArray.count){
        
        cell.email_Lbl.text                 = @"Add account";
        cell.account_ImageView.image        = [UIImage imageNamed:@"ic_add_grey.png"];
        cell.account_ImageView.contentMode  = UIViewContentModeScaleAspectFit;
    }else{
        AppUser *user                       = accountsArray[indexPath.row];
        cell.account_ImageView.image        = [self getUserImageFromDirector:user.email];
        cell.email_Lbl.text                 = user.email;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == accountsArray.count+1)
    {
        [AccountTableDelegate loadController:5];
        
    }else if (indexPath.row == accountsArray.count){
        
        [AccountTableDelegate loadController:4];
        
    }else{
        [AccountTableDelegate useSelectedAccount:accountsArray withIndex:indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

-(UIImage *)getUserImageFromDirector:(NSString *)email{
    
    NSArray *paths          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    NSString *filePath      = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",email]];
    NSData *pngData         = [NSData dataWithContentsOfFile:filePath];
    UIImage *image          = [UIImage imageWithData:pngData];
    return image;
}

@end
