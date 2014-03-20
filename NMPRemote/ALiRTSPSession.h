//
//  ALiRTSPSession.h
//  NMPRemote
//
//  Created by Marc Gandillon on 19.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSatipServer.h"

@interface ALiRTSPSession : NSObject <NSStreamDelegate>

@property (nonatomic, copy) ALiSatipServer *server;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) BOOL unicast;
@property (nonatomic, assign) unsigned short rtpClientPort;
@property (nonatomic, assign) unsigned short rtcpClientPort;

- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url;
- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url rtpClientPort:(unsigned short)rtpClientPort rtcpClientPort:(unsigned short)rtcpClientPort unicast:(BOOL)unicast;

- (void)initNetworkCommunication;

- (void)setup;
- (void)play;
- (void)options;
- (void)teardown;
- (void)describe;

@end
