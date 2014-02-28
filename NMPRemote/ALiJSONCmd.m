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



- (NSString *)generatePlaybackRequest:(NSString *)url
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

- (NSString *)generateStopPlaybackRequest
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

@end
