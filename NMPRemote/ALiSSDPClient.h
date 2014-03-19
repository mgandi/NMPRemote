//
//  ALiSSDPClient.h
//  NMPRemote
//
//  Created by Marc Gandillon on 13.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSSDPDevice.h"

@class ALiSSDPClient;

@protocol ALiSSDPClientDelegate <NSObject>
- (void)SSDPDeviceJoin:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device;
- (void)SSDPDeviceLeft:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device;
- (void)foundSSDPDevice:(ALiSSDPClient *)ssdpClient device:(ALiSSDPDevice *)device;
@end

@interface ALiSSDPClient : NSObject <NSStreamDelegate>

@property (nonatomic, weak) id <ALiSSDPClientDelegate> delegate;

- (id)init;
- (void)searchForDevices:(NSString *)urn;

@end
