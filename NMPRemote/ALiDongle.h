//
//  ALiDongle.h
//  NMPRemote
//
//  Created by Abilis Systems on 24/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiJSONCmd.h"

#define APP_VERSION_MAJOR 1
#define APP_VERSION_MINOR 6

@class ALiDongle;

@protocol ALiDongleDelegate <NSObject>
- (void)appInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict;
- (void)deviceInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict;
- (void)deviceWifiInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict;
- (void)deviceWifiChannelInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict;
- (void)deviceWifiListInformationReceived:(ALiDongle *)dongle dict:(NSDictionary *)dict;
@end

@interface ALiDongle : NSObject

@property (nonatomic, weak) id <ALiDongleDelegate> delegate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

- (id)init;

- (void)queryInformationAsync:(Boolean)encode message:(NSString *)message;
- (NSDictionary *)queryInformationSync:(Boolean)encode message:(NSString *)message;
- (void)sendCommand:(Boolean)encode message:(NSString *)message;

- (Boolean)checkAppVersionMatch;

- (void)getAppVersionInfo;
- (void)getDeviceInfo;
- (void)getDeviceWifiInfo;
- (void)getDeviceWifiChannelInfo;
- (void)getDeviceWifiIsScanningInfo;
- (void)getDeviceWifiListInfo;
- (void)connectToWifi:(NSString *)ssid protection:(NSString *)protection password:(NSString *)password hidden:(BOOL)hidden;

- (void)playback:(NSString *)url;
- (void)stopPlayback;
- (void)switchToMainpage;
- (void)switchToIpla;
- (void)switchToYoutube;
- (void)switchToWebpage:(NSString *)url;
- (void)emulateKey:(NSInteger)code;

+ (NSString *)base64String:(NSString *)str;

@end
