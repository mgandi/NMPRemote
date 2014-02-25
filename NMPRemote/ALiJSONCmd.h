//
//  ALiJSONCmd.h
//  NMPRemote
//
//  Created by Abilis Systems on 25/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALiJSONCmd;

@protocol ALiJSONCmdDelegate <NSObject>
- (void)appInfoReceived:(NSDictionary *)dict;
- (void)deviceInfoReceived:(NSDictionary *)dict;
@end

@interface ALiJSONCmd : NSObject

@property (nonatomic, weak) id <ALiJSONCmdDelegate> delegate;

- (NSDictionary *)parse:(NSString *)JSONString;

- (NSString *)generateAppInfoRequest;
- (NSString *)generateDeviceInfoRequest;

@end
