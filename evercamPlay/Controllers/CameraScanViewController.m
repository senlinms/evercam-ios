//
//  CameraScanViewController.m
//  evercamPlay
//
//  Created by Zulqarnain on 6/1/16.
//  Copyright © 2016 evercom. All rights reserved.
//

#import "CameraScanViewController.h"
#import "CameraScanCell.h"
#import "GlobalSettings.h"
#import "EvercamCameraVendor.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "Device.h"
#import "AllDevicesViewController.h"

#include <sys/param.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
//#include <net/if_types.h>
//#include <netinet/if_ether.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <err.h>
#include <errno.h>
#include <netdb.h>
#include <paths.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
//#import <net/route.h>
//#import "route.h"
#include "if_ether.h"
//#include "route.h"
#include "if_arp.h"
#include "if_dl.h"
#include "if_types.h"
#if TARGET_IPHONE_SIMULATOR
#include <net/route.h>
#define TypeEN    "en1"
#else
#include "route.h"
#define TypeEN    "en0"
#endif
@interface CameraScanViewController (){
    NSMutableArray *connctedDevices;
    NSMutableArray *otherDevicesArray;
    ScanLAN *lanScanner;
}
@property (nonatomic,strong) ScanLAN *lanScanner;
@property (nonatomic,strong) NSMutableArray *connctedDevices;
@property (nonatomic,strong) NSMutableArray *otherDevicesArray;
@end

@implementation CameraScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        [self.camera_Table registerNib:[UINib nibWithNibName:([GlobalSettings sharedInstance].isPhone)?@"CameraScanCell":@"CameraScanCell_iPad" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    [self startScanningLAN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.lanScanner stopScan];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)startScanningLAN {
    self.camera_Table.userInteractionEnabled = NO;
    self.otherDevicesBtn.enabled    = NO;
    [self.lanScanner stopScan];
    self.lanScanner                 = [[ScanLAN alloc] initWithDelegate:self];
    self.connctedDevices            = [[NSMutableArray alloc] init];
    self.otherDevicesArray          = [[NSMutableArray alloc] init];
    [self.lanScanner startScan];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scan_Other_Devices:(id)sender {
    AllDevicesViewController *aVC = [[AllDevicesViewController alloc] initWithNibName:([GlobalSettings sharedInstance].isPhone)?@"AllDevicesViewController":@"AllDevicesViewController_iPad" bundle:[NSBundle mainBundle]];
    aVC.devicesArray = self.otherDevicesArray;
    [self.navigationController pushViewController:aVC animated:YES];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.connctedDevices.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CameraScanCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CameraScanCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    Device *device              = [self.connctedDevices objectAtIndex:indexPath.row];
    cell.camera_Name_Lbl.text   = device.name;
    cell.ip_Address_Lbl.text    = device.address;
    [cell.camera_Thumb_ImageView sd_setImageWithURL:[NSURL URLWithString:device.image_url] placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
    
    const char *c   = [address UTF8String];
    NSString * complete_Mac_Address = [self getCompleteMacAddress:[self ip2mac:c]];
    NSLog(@"MAC ADDRESS: %@",complete_Mac_Address);
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:complete_Mac_Address,@"mac_address",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    [self.scanning_activityindicator startAnimating];
    [EvercamCameraVendor getVendorName:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSDictionary *camDict = details;
            NSArray *vendorArray = camDict[@"vendors"];
            if (vendorArray.count > 0) {
                NSDictionary *dict  = vendorArray[0];
                Device *device      = [[Device alloc] init];
                device.name         = dict[@"id"];
                device.address      = address;
                device.mac_Address  = complete_Mac_Address;
                device.image_url    = [NSString stringWithFormat:@"https://evercam-public-assets.s3.amazonaws.com/%@/%@_default/thumbnail.jpg",dict[@"id"],dict[@"id"]];
                [self.connctedDevices addObject:device];
                [self.camera_Table reloadData];
            }else{
                Device *device      = [[Device alloc] init];
                device.name         = hostName;
                device.address      = address;
                device.mac_Address  = complete_Mac_Address;
                device.image_url    = @"";
                [self.otherDevicesArray addObject:device];
            }

        }else{
//            [self showErrorMessage];
        }
    }];
    [self.camera_Table reloadData];
}

-(void)showErrorMessage{
    [self.scanning_activityindicator stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(NSString *)getCompleteMacAddress:(NSString *)mac{
    NSMutableArray *mac_Address_Array = [[mac componentsSeparatedByString:@":"] mutableCopy];
    [mac_Address_Array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.length < 2) {
            NSString *strings = obj;
            strings = [NSString stringWithFormat:@"0%@",strings];
            [mac_Address_Array replaceObjectAtIndex:idx withObject:strings];
        }
    }];
    return [[mac_Address_Array valueForKey:@"description"] componentsJoinedByString:@":"];
}

- (void)scanLANDidFinishScanning {
    NSLog(@"Scan finished");
    [self.scanning_activityindicator stopAnimating];
    self.camera_Table.userInteractionEnabled = YES;
    self.otherDevicesBtn.enabled = YES;
}


-(NSString*) ip2mac: (char*) ip
{
    static int nflag;
    int expire_time, flags, export_only, doing_proxy, found_entry;
    
    NSString *mAddr = nil;
    u_long addr = inet_addr(ip);
    int mib[6];
    size_t needed;
    char *host, *lim, *buf, *next;
    struct rt_msghdr *rtm;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    extern int h_errno;
    struct hostent *hp;
    
    mib[0] = CTL_NET;
    mib[1] = PF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_INET;
    mib[4] = NET_RT_FLAGS;
    mib[5] = RTF_LLINFO;
    if (sysctl(mib, 6, NULL, &needed, NULL, 0) < 0)
        err(1, "route-sysctl-estimate");
    if ((buf = malloc(needed)) == NULL)
        err(1, "malloc");
    if (sysctl(mib, 6, buf, &needed, NULL, 0) < 0)
        err(1, "actual retrieval of routing table");
    
   
    lim = buf + needed;
    for (next = buf; next < lim; next += rtm->rtm_msglen) {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        if (addr) {
            if (addr != sin->sin_addr.s_addr)
                continue;
            found_entry = 1;
        }
        if (nflag == 0)
            hp = gethostbyaddr((caddr_t)&(sin->sin_addr),
                               sizeof sin->sin_addr, AF_INET);
        else
            hp = 0;
        if (hp)
            host = hp->h_name;
        else {
            host = "?";
            if (h_errno == TRY_AGAIN)
                nflag = 1;
        }
        
        if (sdl->sdl_alen) {
            
            u_char *cp = LLADDR(sdl);
            
            mAddr = [NSString stringWithFormat:@"%x:%x:%x:%x:%x:%x", cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
            
            
            //  ether_print((u_char *)LLADDR(sdl));
        }
        else
            
            mAddr = nil;
        
        
        
    }
    
    if (found_entry == 0) {
        return nil;
    } else {
        return mAddr;
    }
}

@end
