//
//  ALiJSONCmd.h
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ProtocolIDs {
	NMP_CMD_ID_IDENTIFY = 1,
	NMP_CMD_ID_WIFILIST = 2,
	NMP_CMD_ID_WIFICONNECT = 3,
	NMP_CMD_ID_WIFIDISCONNECT = 4,
	NMP_CMD_ID_DEVICEINFO = 5,
	NMP_CMD_ID_WIFICONFIG = 6,
	NMP_CMD_ID_WIFIISCONNECTED = 7,
	NMP_CMD_ID_WIFILIST_GENERATE = 8,
	NMP_CMD_ID_UPGRADE = 9,
	NMP_CMD_ID_CHANGECHANNEL = 10,
	NMP_CMD_ID_GETCHANNEL = 11,
	NMP_CMD_ID_APKINFO = 12,
	NMP_CMD_ID_PLAYBACKPLAY = 13,
	NMP_CMD_ID_PLAYBACKSTOP = 14,
	NMP_CMD_ID_EMULATE_KEY = 15,
	NMP_CMD_ID_SWITCH_TO_WEBKIT = 16,
	NMP_CMD_ID_SWITCH_TO_MAINPAGE = 17,
	NMP_CMD_ID_PLAYBACK_SEEK_TIME = 18,
	NMP_CMD_ID_PLAYBACK_NOW_TIME = 19,
	NMP_CMD_ID_PLAYBACK_MAX_TIME = 20,
	NMP_CMD_ID_UPG_PARTITION_UPGRADE = 21
};

@interface ALiJSONCmd : NSObject

- (NSDictionary *)parse:(NSString *)JSONString;

- (NSString *)generateAppInfoRequest;
- (NSString *)generateDeviceInfoRequest;
- (NSString *)generateDeviceWifiInfoRequest;
- (NSString *)generateDeviceWifiChannelInfoRequest;

- (NSString *)generatePlaybackRequest:(NSString *)url;
- (NSString *)generateStopPlaybackRequest;

@end
