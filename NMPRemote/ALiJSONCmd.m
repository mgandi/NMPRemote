//
//  ALiJSONCmd.m
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.

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
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_DEVICEINFO] forKey:@"id"];
    [dict setObject:@"deviceinfo" forKey:@"command"];
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

- (NSString *)generateDeviceWifiInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_WIFIISCONNECTED] forKey:@"id"];
    [dict setObject:@"wifiisconnected" forKey:@"command"];
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

- (NSString *)generateDeviceWifiChannelInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_GETCHANNEL] forKey:@"id"];
    [dict setObject:@"getchannel" forKey:@"command"];
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

- (NSString *)generateWifiScanningInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_WIFILIST_GENERATE] forKey:@"id"];
    [dict setObject:@"wifiscanning" forKey:@"command"];
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

- (NSString *)generateWifiListInfoRequest
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_WIFILIST] forKey:@"id"];
    [dict setObject:@"wifilist" forKey:@"command"];
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

- (NSString *)generateConnectToWifiRequest:(NSString *)ssid protection:(NSString *)protection password:(NSString *)password hidden:(BOOL)hidden
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    NSMutableDictionary *subDict = [[NSMutableDictionary alloc ] init];
    
    [subDict setObject:ssid forKey:@"ssid"];
    [subDict setObject:protection forKey:@"protect"];
    [subDict setObject:password forKey:@"password"];
    [subDict setObject:(hidden ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]) forKey:@"hidden"];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_WIFICONNECT] forKey:@"id"];
    [dict setObject:@"wificonnect" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    [dict setObject:subDict forKey:@"target"];
    
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



- (NSString *)generatePlaybackCmd:(NSString *)url
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_PLAYBACKPLAY] forKey:@"id"];
    [dict setObject:@"setplaybackplay" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    [dict setObject:url forKey:@"url"];
    
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

- (NSString *)generateStopPlaybackCmd
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_PLAYBACKSTOP] forKey:@"id"];
    [dict setObject:@"setplaybackstop" forKey:@"command"];
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

- (NSString *)generateSwitchToMainPageCmd
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_SWITCH_TO_MAINPAGE] forKey:@"id"];
    [dict setObject:@"switchtomainpage" forKey:@"command"];
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

- (NSString *)generateSwitchToWebkitCmd:(NSInteger)type url:(NSString *)url
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_SWITCH_TO_WEBKIT] forKey:@"id"];
    [dict setObject:@"switchtowebkit" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    [dict setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [dict setObject:url forKey:@"url"];
    
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

- (NSString *)generateEmultaeKeyCmd:(NSInteger)code
{
    NSString *JSONString = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    
    [dict setObject:[NSNumber numberWithInt:NMP_CMD_ID_EMULATE_KEY] forKey:@"id"];
    [dict setObject:@"emulatekey" forKey:@"command"];
    [dict setObject:[NSNumber numberWithInt:session++] forKey:@"session"];
    [dict setObject:[NSString stringWithFormat:@"%d", code] forKey:@"key"];
    
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
