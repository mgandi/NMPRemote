//
//  ALiSatipServer.h
//  NMPRemote
//
//  Created by Abilis Systems on 18/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSSDPDevice.h"

@interface ALiSatipServer : NSObject <NSXMLParserDelegate>

@property (nonatomic, copy) ALiSSDPDevice *device;

- (id)initWithSSDPDevice:(ALiSSDPDevice *)device;

- (NSString *)getFriendlyName;

@end
