#import <Foundation/Foundation.h>
#import "EvercamRights.h"

@interface EvercamCamera : NSObject
@property (nonatomic, strong) NSString* camId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* owner;
@property (nonatomic, strong) EvercamRights *rights;
@property (nonatomic, assign) BOOL hasCredentials;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* vendor;
@property (nonatomic, strong) NSString* model;
@property (nonatomic, strong) NSString* macAddress;


@property (nonatomic, strong) NSString *externalJpgUrl;
@property (nonatomic, strong) NSString *externalH264Url;
@property (nonatomic, strong) NSString *externalHost;
@property (nonatomic, assign) int externalHttpPort;
@property (nonatomic, assign) int externalRtspPort;

@property (nonatomic, strong) NSString *internalJpgUrl;
@property (nonatomic, strong) NSString *internalH264Url;
@property (nonatomic, strong) NSString *internalHost;
@property (nonatomic, assign) int internalHttpPort;
@property (nonatomic, assign) int internalRtspPort;
@property (nonatomic, strong) NSString* timezone;

@property (nonatomic, assign) BOOL isOnline;

@property (nonatomic, strong) NSString *hlsUrl;
@property (nonatomic, strong) NSString *rtmpUrl;
@property (nonatomic, strong) NSString *model_id;
@property (nonatomic,assign)  BOOL is_Public;
@property (nonatomic,assign)  BOOL is_Discoverable;

@property (nonatomic)  double latitude;
@property (nonatomic)  double longitude;

- (id) initWithDictionary: (NSDictionary *)cameraDict;
- (BOOL) isHikvision;
- (NSString *)getJpgPath;
- (NSString *)getRTSPUrl;
@end

