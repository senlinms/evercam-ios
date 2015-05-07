//
//  SettingsViewController.m
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 evercom. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "PreferenceUtil.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Cameras Preferences";
    
    // Do any additional setup after loading the view from its nib.
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.tableView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:39.0/255.0 green:45.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], nil];
    [self.tableView.layer insertSublayer:gradient atIndex:0];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [self.btnMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)landscapeModeChanged:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]) {
        [PreferenceUtil setIsForceLandscape:YES];
    } else {
        [PreferenceUtil setIsForceLandscape:NO];
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 3;
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    [headerView setBackgroundColor:[UIColor lightTextColor]];
    
    UILabel *hLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width - 20, 30)];
    hLabel.backgroundColor=[UIColor clearColor];
    hLabel.textColor = [UIColor lightGrayColor];  // or whatever you want
    hLabel.font = [UIFont boldSystemFontOfSize:14];
    if (section == 0)
        hLabel.text = @"GENERAL";
    else
        hLabel.text = @"ABOUT";
    
    [headerView addSubview:hLabel];
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subTitleCellIdentifier = @"SubtitleCell";
    static NSString *basicCellIdentifier = @"BasicCell";
    
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subTitleCellIdentifier];
            cell.textLabel.text = @"Cameras per row";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [PreferenceUtil getCameraPerRow]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 1)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subTitleCellIdentifier];
            cell.textLabel.text = @"Sleep";
            
            NSInteger sleepTimerSecs = [PreferenceUtil getSleepTimerSecs];
            if (sleepTimerSecs == 0) {
                cell.detailTextLabel.text = @"Never";
            } else if (sleepTimerSecs == 60) {
                cell.detailTextLabel.text = @"After 1 minute of inactivity";
            } else if (sleepTimerSecs == 5 * 60) {
                cell.detailTextLabel.text = @"After 5 minutes of inactivity";
            } else if (sleepTimerSecs == 30) {
                cell.detailTextLabel.text = @"After 30 seconds of inactivity";
            }
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicCellIdentifier];
            cell.textLabel.text = @"Force landscape for live view";
            cell.textLabel.textColor = [UIColor whiteColor];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 11.5f, 51.f, 31.f)];
            [cell addSubview:swtch];
            [swtch addTarget:self action:@selector(landscapeModeChanged:) forControlEvents:UIControlEventValueChanged];
            
            if ([PreferenceUtil isForceLandscape]) {
                [swtch setOn:YES];
            } else {
                [swtch setOn:NO];
            }
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
            NSString *build = infoDictionary[(NSString*)@"CFBundleShortVersionString"];
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subTitleCellIdentifier];
            cell.textLabel.text = @"Version";
            cell.detailTextLabel.text = build;
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.detailTextLabel.textColor = [UIColor whiteColor];
        }
        else if (indexPath.row == 1)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicCellIdentifier];
            cell.textLabel.text = @"About Evercam";
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.backgroundView.backgroundColor = [UIColor colorWithRed:52.f/255.f green:57.f/255.f blue:61.f/255.f alpha:1];
    cell.backgroundColor = [UIColor colorWithRed:26.f/255.f green:30.f/255.f blue:35.f/255.f alpha:1];
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * view=   [UIAlertController
                                             alertControllerWithTitle:@"Cameras per row"
                                             message:nil
                                             preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction* one = [UIAlertAction
                                      actionWithTitle:@"1"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          //Do some thing here
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setCameraPerRow:1];
                                          [self.tableView reloadData];
                                      }];
                UIAlertAction* two = [UIAlertAction
                                      actionWithTitle:@"2"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setCameraPerRow:2];
                                          [self.tableView reloadData];
                                          
                                      }];
                UIAlertAction* three = [UIAlertAction
                                      actionWithTitle:@"3"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setCameraPerRow:3];
                                          [self.tableView reloadData];
                                          
                                      }];
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * action)
                                         {
                                             [view dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                
                
                [view addAction:one];
                [view addAction:two];
                [view addAction:three];
                [view addAction:cancel];
                [self presentViewController:view animated:YES completion:nil];
            });
        }
        else if (indexPath.row == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController * view=   [UIAlertController
                                             alertControllerWithTitle:@"Sleep"
                                             message:nil
                                             preferredStyle:UIAlertControllerStyleActionSheet];
                
                UIAlertAction* halfmin = [UIAlertAction
                                      actionWithTitle:@"30 seconds"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          //Do some thing here
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setSleepTimerSecs:30];
                                          [self.tableView reloadData];
                                      }];
                UIAlertAction* onemin = [UIAlertAction
                                      actionWithTitle:@"1 minute"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setSleepTimerSecs:60];
                                          [self.tableView reloadData];
                                      }];
                UIAlertAction* fivemin = [UIAlertAction
                                      actionWithTitle:@"5 minute"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setSleepTimerSecs:5 * 60];
                                          [self.tableView reloadData];
                                      }];
                UIAlertAction* never = [UIAlertAction
                                      actionWithTitle:@"Never"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setSleepTimerSecs:0];
                                          [self.tableView reloadData];
                                          
                                      }];
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Cancel"
                                         style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * action)
                                         {
                                             [view dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                
                
                [view addAction:halfmin];
                [view addAction:onemin];
                [view addAction:fivemin];
                [view addAction:never];
                [view addAction:cancel];
                [self presentViewController:view animated:YES completion:nil];
            });

        }
        else if (indexPath.row == 2)
        {
//            if ([self.tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
//                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
//                [PreferenceUtil setIsForceLandscape:NO];
//            } else {
//                [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//                [PreferenceUtil setIsForceLandscape:YES];
//            }

        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.evercam.io"]];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
@end
