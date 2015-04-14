//
//  SelectVendorViewController.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "SelectVendorViewController.h"
#import "EvercamShell.h"
#import "EvercamVendor.h"
#import "MBProgressHUD.h"

@interface SelectVendorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *vendorsArray;

@end

@implementation SelectVendorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self getAllVendors];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAllVendors {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[EvercamShell shell] getAllVendors:^(NSArray *vendors, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.vendorsArray = vendors;
        [self.tableView reloadData];
    }];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Datasource and Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.vendorsArray) {
        return self.vendorsArray.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [UITableViewCell new];
        [cell setBackgroundColor:[UIColor blackColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    EvercamVendor *vendor = [self.vendorsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = vendor.name;
    
    if ([self.selectedVendor.vId isEqualToString:vendor.vId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EvercamVendor *vendor = [self.vendorsArray objectAtIndex:indexPath.row];

    if (!self.selectedVendor || ![self.selectedVendor.vId isEqualToString:vendor.vId]) {
        if ([self.delegate respondsToSelector:@selector(vendorChanged:)]) {
            [self.delegate vendorChanged:vendor];
        }
    }
    
    [self.tableView reloadData];
    [self back:nil];
}

@end
