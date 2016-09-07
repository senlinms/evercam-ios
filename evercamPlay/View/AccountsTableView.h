//
//  AccountsTableView.h
//  evercamPlay
//
//  Created by Zulqarnain on 9/5/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountTable <NSObject>

-(void)loadController:(NSInteger)row;
-(void)useSelectedAccount:(NSMutableArray *)accountsArray withIndex:(NSInteger)selectedIndex;

@end
@interface AccountsTableView : UITableView<UITableViewDataSource,UITableViewDelegate>{
//    id <AccountTable> AccountTableDelegate;
}

@property (nonatomic,strong) NSMutableArray *accountsArray;
@property (nonatomic,assign) id <AccountTable> AccountTableDelegate;

@end
