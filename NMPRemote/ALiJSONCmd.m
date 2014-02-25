//
//  ALiJSONCmd.m
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.

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

#import "ALiJSONCmd.h"

@implementation ALiJSONCmd
{
    int32_t session;
}

- (NSDictionary *)parse:(NSString *)JSONString
{
    NSDictionary *dict = nil;
    NSLog(@"JSON input: %@", JSONString);
    
    NSData *jsonData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if(!dict) {
        NSLog(@"JSON error: %@", error);
    } else {
        NSNumber *ID = [dict valueForKey:@"id"];
        
        //Do Something
        switch ([ID unsignedIntValue]) {
            case NMP_CMD_ID_APKINFO:
                [self.delegate appInfoReceived:dict];
                break;
                
            case NMP_CMD_ID_DEVICEINFO:
                [self.delegate deviceInfoReceived:dict];
                break;
                
            default:
                break;
        }
    }
    
    return dict;
}

- (NSString *)generateAppInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_APKINFO] forKey:@"id"];
    [dict setObject:@"apkinfo" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
    } else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSLog(@"JSON output: %@", JSONString);
    }
    
    return JSONString;
}

- (NSString *)generateDeviceInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    session = 0;
    
    [dict setObject:@"deviceinfo" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_DEVICEINFO] forKey:@"id"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
    } else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSLog(@"JSON output: %@", JSONString);
    }
    
    return JSONString;
}

@end
