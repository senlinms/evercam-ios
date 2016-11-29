//
//  SettingsViewController.m
//  evercamPlay
//
//  Created by jw on 3/10/15.
//  Copyright (c) 2015 Evercam. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "PreferenceUtil.h"
#import "GlobalSettings.h"
#import "BlockActionSheet.h"
#import "AppDelegate.h"
#import "Struts.h"

@interface SettingsViewController ()
{
    CAGradientLayer *gradient;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.settingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"])];
    CustomNavigationController* cVC = [APP_DELEGATE viewController];
    [cVC setHasLandscapeMode:YES];
    [UIViewController attemptRotationToDeviceOrientation];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews{
    
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}


- (IBAction)landscapeModeChanged:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]) {
        [PreferenceUtil setIsForceLandscape:YES];
    } else {
        [PreferenceUtil setIsForceLandscape:NO];
    }
}

- (IBAction)showOfflineModeChanged:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    if ([switchView isOn]) {
        [PreferenceUtil setIsShowOfflineCameras:YES];
    } else {
        [PreferenceUtil setIsShowOfflineCameras:NO];
    }
}

- (IBAction)BackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subTitleCellIdentifier = @"SubtitleCell";
    static NSString *basicCellIdentifier = @"BasicCell";
    
    UITableViewCell *cell;
    
    if (indexPath.row == 0)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subTitleCellIdentifier];
        cell.textLabel.text = @"Cameras per row";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[PreferenceUtil getCameraPerRow]];
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
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    else if (indexPath.row == 2)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicCellIdentifier];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 54);
        cell.textLabel.text = @"Force landscape for live view";
        cell.textLabel.textColor = [UIColor blackColor];
        
        UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-66 , 11.5f, 51.f, 31.f)];
        [cell addSubview:swtch];
        [swtch addTarget:self action:@selector(landscapeModeChanged:) forControlEvents:UIControlEventValueChanged];
        setstrutsWithMask(swtch, UIViewAutoresizingFlexibleLeftMargin);
        if ([PreferenceUtil isForceLandscape]) {
            [swtch setOn:YES];
        } else {
            [swtch setOn:NO];
        }
    }
    else
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:basicCellIdentifier];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 54);
        cell.textLabel.text = @"Show offline cameras";
        cell.textLabel.textColor = [UIColor blackColor];
        
        UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-66, 11.5f, 51.f, 31.f)];
        [cell addSubview:swtch];
        [swtch addTarget:self action:@selector(showOfflineModeChanged:) forControlEvents:UIControlEventValueChanged];
        
        setstrutsWithMask(swtch, UIViewAutoresizingFlexibleLeftMargin);
        
        if ([PreferenceUtil isShowOfflineCameras]) {
            [swtch setOn:YES];
        } else {
            [swtch setOn:NO];
        }
    }
    
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
                
                [sheet addButtonWithTitle:@"1" block:^{
                    [PreferenceUtil setCameraPerRow:1];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"2" block:^{
                    [PreferenceUtil setCameraPerRow:2];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"3" block:^{
                    [PreferenceUtil setCameraPerRow:3];
                    [self.settingTableView reloadData];
                }];
                
                [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
                [sheet showInView:self.view];
            }
            else
            {
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
                                          [self.settingTableView reloadData];
                                      }];
                UIAlertAction* two = [UIAlertAction
                                      actionWithTitle:@"2"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          [view dismissViewControllerAnimated:YES completion:nil];
                                          [PreferenceUtil setCameraPerRow:2];
                                          [self.settingTableView reloadData];
                                          
                                      }];
                UIAlertAction* three = [UIAlertAction
                                        actionWithTitle:@"3"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [view dismissViewControllerAnimated:YES completion:nil];
                                            [PreferenceUtil setCameraPerRow:3];
                                            [self.settingTableView reloadData];
                                            
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
                
                if ([GlobalSettings sharedInstance].isPhone)
                {
                    [self presentViewController:view animated:YES completion:nil];
                }
                else
                {
                    UIPopoverPresentationController *popPresenter = [view
                                                                     popoverPresentationController];
                    popPresenter.sourceView = [self.settingTableView cellForRowAtIndexPath:indexPath];
                    popPresenter.sourceRect = [self.settingTableView cellForRowAtIndexPath:indexPath].bounds;
                    [self presentViewController:view animated:YES completion:nil];
                }
            }
        });
    }
    else if (indexPath.row == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                BlockActionSheet *sheet = [BlockActionSheet sheetWithTitle:@""];
                
                [sheet addButtonWithTitle:@"Sleep" block:^{
                    [PreferenceUtil setSleepTimerSecs:30];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"30 seconds" block:^{
                    [PreferenceUtil setSleepTimerSecs:30];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"1 minute" block:^{
                    [PreferenceUtil setSleepTimerSecs:60];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"5 minute" block:^{
                    [PreferenceUtil setSleepTimerSecs:5 * 60];
                    [self.settingTableView reloadData];
                }];
                [sheet addButtonWithTitle:@"Never" block:^{
                    [PreferenceUtil setSleepTimerSecs:0];
                    [self.settingTableView reloadData];
                }];
                
                [sheet setCancelButtonWithTitle:@"Cancel" block:nil];
                [sheet showInView:self.view];
            }
            else
            {
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
                                              [self.settingTableView reloadData];
                                          }];
                UIAlertAction* onemin = [UIAlertAction
                                         actionWithTitle:@"1 minute"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [view dismissViewControllerAnimated:YES completion:nil];
                                             [PreferenceUtil setSleepTimerSecs:60];
                                             [self.settingTableView reloadData];
                                         }];
                UIAlertAction* fivemin = [UIAlertAction
                                          actionWithTitle:@"5 minute"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action)
                                          {
                                              [view dismissViewControllerAnimated:YES completion:nil];
                                              [PreferenceUtil setSleepTimerSecs:5 * 60];
                                              [self.settingTableView reloadData];
                                          }];
                UIAlertAction* never = [UIAlertAction
                                        actionWithTitle:@"Never"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [view dismissViewControllerAnimated:YES completion:nil];
                                            [PreferenceUtil setSleepTimerSecs:0];
                                            [self.settingTableView reloadData];
                                            
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
                
                if ([GlobalSettings sharedInstance].isPhone)
                {
                    [self presentViewController:view animated:YES completion:nil];
                }
                else
                {
                    UIPopoverPresentationController *popPresenter = [view
                                                                     popoverPresentationController];
                    popPresenter.sourceView = [self.settingTableView cellForRowAtIndexPath:indexPath];
                    popPresenter.sourceRect = [self.settingTableView cellForRowAtIndexPath:indexPath].bounds;
                    [self presentViewController:view animated:YES completion:nil];
                }
            }
        });
        
    }
    else if (indexPath.row == 2)
    {
        
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
