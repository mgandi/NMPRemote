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
@end

@interface ALiDongle : NSObject <NSStreamDelegate, ALiJSONCmdDelegate>

@property (nonatomic, weak) id <ALiDongleDelegate> delegate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;

- (id)init;
- (void)start;
- (void)sendMessage:(Boolean)encode message:(NSString *)message;

- (void)checkAppMatchDongleVersion;
- (void)getDeviceInfo;

+ (NSString *)base64String:(NSString *)str;

@end
