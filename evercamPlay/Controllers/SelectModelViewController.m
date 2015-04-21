//
//  SelectVendorViewController.m
//  evercamPlay
//
//  Created by jw on 4/13/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "SelectModelViewController.h"
#import "EvercamShell.h"
#import "MBProgressHUD.h"

@interface SelectModelViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self getAllModels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAllModels {
    if (self.selectedVendor) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[EvercamShell shell] getAllModelsByVendorId:self.selectedVendor.vId withBlock:^(NSArray *models, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            self.modelsArray = models;
            [self.tableView reloadData];
        }];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView Datasource and Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.modelsArray) {
        return self.modelsArray.count;
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
    
    EvercamModel *model = [self.modelsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;
    
    if ([self.selectedModel.vId isEqualToString:model.vId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EvercamModel *model = [self.modelsArray objectAtIndex:indexPath.row];

    if (!self.selectedModel || ![self.selectedModel.vId isEqualToString:model.vId]) {
        if ([self.delegate respondsToSelector:@selector(modelChanged:)]) {
            [self.delegate modelChanged:model];
        }
    }
    
    [self.tableView reloadData];
    [self back:nil];
}

@end
