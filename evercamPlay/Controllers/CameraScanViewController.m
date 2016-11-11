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
#import "VendorAndModelViewController.h"
#import "GCDAsyncSocket.h" // for TCP
#import "GCDAsyncUdpSocket.h" // for UDP
#import "EvercamSingleCameraDetails.h"
#import "EvercamUtility.h"

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
    
    //Onvif
    GCDAsyncUdpSocket *udpSocket;
    NSTimer *waitTimer;
    NSMutableArray *cameraObjectsArray;
    NSString *xmlTag;
    Device *onvif_Device;
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
    //    [self startScanningLAN];
    self.connctedDevices    = [[NSMutableArray alloc] init];
    cameraObjectsArray      = [NSMutableArray new];
    [self openSocket];
    [self broadcastMessageOnNetwork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.lanScanner stopScan];
    [udpSocket close];
    if (waitTimer) {
        [waitTimer invalidate];
        waitTimer = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (AppUtility.isFromScannedScreen) {
        AppUtility.isFromScannedScreen = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    cell.backgroundColor        = [UIColor clearColor];
    Device *device              = [self.connctedDevices objectAtIndex:indexPath.row];
    cell.camera_Name_Lbl.text   = [NSString stringWithFormat:@"%@ %@",device.name,(!device.onvif_Camera_model)?@"":device.onvif_Camera_model];
    cell.ip_Address_Lbl.text    = [NSString stringWithFormat:@"%@:%@",device.address,(!device.http_Port)?@"":device.http_Port];
    [cell.camera_Thumb_ImageView sd_setImageWithURL:[NSURL URLWithString:device.image_url] placeholderImage:[UIImage imageNamed:@"ic_GridPlaceholder.png"]];
    [self assignAttributedString:cell.detail_Lbl withDevice:device];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Device *device              = [self.connctedDevices objectAtIndex:indexPath.row];
    [self goToVendorScreen:device];
}

-(void)assignAttributedString:(UILabel *)infoLabel withDevice:(Device *)device{
    
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: infoLabel.textColor,
                              NSFontAttributeName: infoLabel.font
                              };
    
    NSMutableAttributedString * attributedString= [[NSMutableAttributedString alloc] initWithString:@"IP   VENDOR   MODEL   HTTP   RTSP   AUTH   EVERCAM" attributes:attribs];
    UIColor *greenColor = [AppUtility colorWithHexString:@"869550"];
    UIColor *greyColor  = [AppUtility colorWithHexString:@"B2B2B2"];
    
    if (device.address) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(0,2)];
    }else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:greyColor range:NSMakeRange(0,2)];
    }
    
    if (device.vendorId) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(5,6)];
    }else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:greyColor range:NSMakeRange(5,6)];
    }
    
    if (device.onvif_Camera_model) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(14,5)];
    }else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:greyColor range:NSMakeRange(14,5)];
    }
    if (device.http_Port) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(22,4)];
    }else{
        [attributedString addAttribute:NSForegroundColorAttributeName value:greyColor range:NSMakeRange(22,4)];
    }
    [attributedString addAttribute:NSForegroundColorAttributeName value:greyColor range:NSMakeRange(29,21)];
    infoLabel.attributedText = attributedString;
}


#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
    
    const char *c   = [address UTF8String];
    NSString * complete_Mac_Address = [self getCompleteMacAddress:[self ip2mac:c]];
    NSString *required_Mac_Address =  [complete_Mac_Address substringToIndex:8];
    NSLog(@"MAC ADDRESS: %@",complete_Mac_Address);
    NSDictionary *param_Dictionary = [NSDictionary dictionaryWithObjectsAndKeys:required_Mac_Address,@"mac_address",[APP_DELEGATE defaultUser].apiId,@"api_id",[APP_DELEGATE defaultUser].apiKey,@"api_Key", nil];
    [self.scanning_activityindicator startAnimating];
    EvercamCameraVendor *api_vendor_Obj = [EvercamCameraVendor new];
    [api_vendor_Obj getVendorName:param_Dictionary withBlock:^(id details, NSError *error) {
        if (!error) {
            NSLog(@"Server Response: %@",details);
            NSDictionary *camDict = details;
            NSArray *vendorArray = camDict[@"vendors"];
            if (vendorArray.count > 0) {
                NSDictionary *dict  = vendorArray[0];
                Device *device      = [[Device alloc] init];
                device.name         = dict[@"name"];
                device.vendorId     = dict[@"id"];
                device.address      = address;
                device.mac_Address  = complete_Mac_Address;
                device.image_url    = [NSString stringWithFormat:@"https://evercam-public-assets.s3.amazonaws.com/%@/%@_default/thumbnail.jpg",dict[@"id"],dict[@"id"]];
                [self checkDuplicateIP:address withDevice:device withServerResponse:dict];
                [self.connctedDevices addObject:device];
                [self.camera_Table reloadData];
            }else{
                Device *device      = [[Device alloc] init];
                device.name         = hostName;
                device.address      = address;
                device.mac_Address  = complete_Mac_Address;
                device.image_url    = @"";
                
                NSArray *array      =  [self checkIPExistence:address];
                
                if (array.count > 0) {
                    //Failed to get vendor info, but camera found via onvif, so add this to found camera list
                    Device *existing_device     = array[0];
                    device.http_Port            = existing_device.http_Port;
                    device.onvif_Camera_model   = existing_device.onvif_Camera_model;
                    [self.connctedDevices addObject:device];
                    [self.camera_Table reloadData];
                }else{
                    [self.otherDevicesArray addObject:device];
                }
            }
            
        }else{
            //            [self showErrorMessage];
        }
    }];
    [self.camera_Table reloadData];
}

-(void)checkDuplicateIP:(NSString *)IPAddress withDevice:(Device *)device withServerResponse:(NSDictionary *)dict{
    
    NSArray *array                  =  [self checkIPExistence:IPAddress];
    
    if (array.count > 0) {
        //Camera found via onvif discovery for same IP address, so just update the information
        Device *existing_device     = array[0];
        device.http_Port            = existing_device.http_Port;
        device.onvif_Camera_model   = existing_device.onvif_Camera_model;
        device.image_url            = [NSString stringWithFormat:@"https://evercam-public-assets.s3.amazonaws.com/%@/%@/thumbnail.jpg",dict[@"id"],[device.onvif_Camera_model lowercaseString]];
        
    }
}

-(NSArray *)checkIPExistence:(NSString *)ip{
    
    NSArray *array =  [cameraObjectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K LIKE[c] %@", @"address", ip]];
    return array;
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
    [cameraObjectsArray removeAllObjects];
    [self.scanning_activityindicator stopAnimating];
    self.camera_Table.userInteractionEnabled = YES;
    self.otherDevicesBtn.enabled = YES;
    if (self.connctedDevices.count > 0) {
        
        [self hideandShowTable:NO withButton:YES withLabel:YES];
        [self.camera_Table reloadData];
        
    }else{
        
        [self hideandShowTable:YES withButton:NO withLabel:NO];
        
        self.otherDevicesBtn.frame = CGRectMake(self.otherDevicesBtn.frame.origin.x, self.addCameraBtn.frame.origin.y + self.addCameraBtn.frame.size.height + 20, self.otherDevicesBtn.frame.size.width, self.otherDevicesBtn.frame.size.height);
    }
    
}

-(void)hideandShowTable:(BOOL)isTblShow withButton:(BOOL)isBthShow withLabel:(BOOL)isLblShow{
    self.cautionLabel.hidden = isLblShow;
    self.addCameraBtn.hidden = isBthShow;
    self.camera_Table.hidden = isTblShow;
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

- (IBAction)addCamera:(id)sender {
    [self goToVendorScreen:nil];
}

-(void)goToVendorScreen:(Device *)scannedDevice{
    VendorAndModelViewController *addCameraVC = [[VendorAndModelViewController alloc] initWithNibName:[GlobalSettings sharedInstance].isPhone ? @"VendorAndModelViewController" : @"VendorAndModelViewController_iPad" bundle:[NSBundle mainBundle]];
    addCameraVC.scanned_Device          = scannedDevice;
    addCameraVC.vendorIdentifier        = scannedDevice.vendorId;
    AppUtility.isFromScannedScreen      = YES;
    CustomNavigationController *navVC   = [[CustomNavigationController alloc] initWithRootViewController:addCameraVC];
    navVC.isPortraitMode                = YES;
    [navVC setHasLandscapeMode:YES];
    navVC.navigationBarHidden           = YES;
    [self.navigationController presentViewController:navVC animated:YES completion:nil];
}

#pragma Onvif implementation

-(void)openSocket{
    
    [self.scanning_activityindicator startAnimating];
    
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    if (![udpSocket bindToPort:3702 error:&error])
    {
        NSLog(@"Error binding to port: %@", error);
        return;
    }
    if(![udpSocket joinMulticastGroup:@"239.255.255.250" error:&error]){
        NSLog(@"Error connecting to multicast group: %@", error);
        return;
    }
    if (![udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    [udpSocket enableBroadcast:YES error: &error];
    
    [udpSocket setIPv4Enabled:YES];
    [udpSocket setIPv6Enabled:NO];
}

-(void)broadcastMessageOnNetwork{
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString *msg = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><e:Envelope xmlns:e=\"http://www.w3.org/2003/05/soap-envelope\"xmlns:w=\"http://schemas.xmlsoap.org/ws/2004/08/addressing\"xmlns:d=\"http://schemas.xmlsoap.org/ws/2005/04/discovery\"xmlns:dn=\"http://www.onvif.org/ver10/network/wsdl\"><e:Header><w:MessageID>uuid:%@</w:MessageID><w:To e:mustUnderstand=\"true\">urn:schemas-xmlsoap-org:ws:2005:04:discovery</w:To><w:Action e:mustUnderstand=\"true\">http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</w:Action></e:Header><e:Body><d:Probe><d:Types>dn:NetworkVideoTransmitter</d:Types></d:Probe></e:Body></e:Envelope>",uuid];
    
    
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [udpSocket sendData:data toHost:@"239.255.255.250" port:3702 withTimeout:-1 tag:0.0];
}


#pragma GCDAsyncUdpSocket Delegate Methods

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"Socket didSendDataWithTag: %ld",tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"Socket didNotSendDataWithTag: %@",error.localizedDescription);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg)
    {
        NSLog(@"message: %@",msg);
        if (waitTimer) {
            [waitTimer invalidate];
            waitTimer = nil;
        }
        waitTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(closeSocket) userInfo:nil repeats:NO];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate = self;
        [parser parse];
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"Socket closed: %@",error.localizedDescription);
}

//End GCDAsyncUdpSocket Delegate methods


#pragma NSXMLPARSER Delegate Methods
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    //the parser started this document. what are you going to do?
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"d:Scopes"]) {
        
        xmlTag = elementName;
        
    }else if ([elementName isEqualToString:@"d:XAddrs"]){
        
        xmlTag = elementName;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([xmlTag isEqualToString:@"d:Scopes"]) {
        //Contains vendor and model information
        onvif_Device                = [[Device alloc] init];
        onvif_Device.name           = string;
        xmlTag = nil;
        
    }else if ([xmlTag isEqualToString:@"d:XAddrs"]){
        NSLog(@"foundCharacters: %@",string);
        //Contains IP Address and Http Port information
        onvif_Device.address = string;
        xmlTag = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    //the parser finished. what are you going to do?
    NSLog(@"parserDidEndDocument");
    if (onvif_Device) {
        
        if (cameraObjectsArray.count > 0) {
            NSArray *array =  [cameraObjectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[c] %@", @"address", onvif_Device.address]];
            if (array.count == 0) {
                [cameraObjectsArray addObject:onvif_Device];
            }
            
        }else{
            [cameraObjectsArray addObject:onvif_Device];
        }
        
        
    }
}

//End NSXMLPARSER Delegate Methods



-(void)closeSocket{
    [udpSocket close];
    
    NSLog(@"Objects Array: %lu",(unsigned long)cameraObjectsArray.count);
    for (Device *onvif_obj in cameraObjectsArray) {
        
        NSString *httpPort      = [self getHttpPort:onvif_obj.address];
        NSString *ipAddress     = [self getIpAddress:onvif_obj.address];
        NSString *model         = [self getCameraModel:onvif_obj.name];
        NSString *vendor        = [self getCameraVendor:onvif_obj.name];
        
        onvif_obj.name                  = vendor;
        onvif_obj.onvif_Camera_model    = model;
        onvif_obj.http_Port             = httpPort;
        onvif_obj.address               = ipAddress;
        /*
         NSArray *array =  [self.connctedDevices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K contains[c] %@", @"address", ipAddress]];
         if (array.count > 0) {
         NSLog(@"Duplicate ip");
         Device *existing_device= array[0];
         existing_device.http_Port = httpPort;
         existing_device.onvif_Camera_model = model;
         //            [cameraObjectsArray removeObject:onvif_obj];
         }else{
         onvif_obj.name                  = vendor;
         onvif_obj.onvif_Camera_model    = model;
         onvif_obj.http_Port             = httpPort;
         onvif_obj.address               = ipAddress;
         }
         */
    }
    NSLog(@"array: %@",cameraObjectsArray);
    [self startScanningLAN];
}

-(NSString *)getCameraModel:(NSString *)onvifString{
    
    NSString *camera_model = [onvifString substringFromIndex:[onvifString rangeOfString: @"onvif://www.onvif.org/hardware/"].location];
    
    NSString *model = [[camera_model substringWithRange: NSMakeRange(0, [camera_model rangeOfString: @" "].location)] stringByReplacingOccurrencesOfString:@"onvif://www.onvif.org/hardware/" withString:@""];
    
    return model;
}

-(NSString *)getCameraVendor:(NSString *)onvifString{
    
    NSString *camera_Vendor = [onvifString substringFromIndex:[onvifString rangeOfString: @"onvif://www.onvif.org/name/"].location];
    
    NSString *vendor = [[camera_Vendor substringWithRange: NSMakeRange(0, [camera_Vendor rangeOfString: @" "].location)] stringByReplacingOccurrencesOfString:@"onvif://www.onvif.org/name/" withString:@""];
    
    return vendor;
}

-(NSString *)getHttpPort:(NSString *)onvifString{
    
    NSString *httpPort;
    
    NSString *firstString = [onvifString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    NSString *secondString = [firstString substringWithRange: NSMakeRange(0, [firstString rangeOfString: @"/"].location)];
    
    NSArray *port_localIp_Array = [secondString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    if (port_localIp_Array.count > 0) {
        httpPort = port_localIp_Array[1];
    }
    return httpPort;
}

-(NSString *)getIpAddress:(NSString *)onvifString{
    
    NSString *ipAddress;
    
    NSString *firstString = [onvifString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    NSString *secondString = [firstString substringWithRange: NSMakeRange(0, [firstString rangeOfString: @"/"].location)];
    
    NSArray *port_localIp_Array = [secondString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    if (port_localIp_Array.count > 0) {
        ipAddress = port_localIp_Array[0];
    }
    return ipAddress;
}

@end
