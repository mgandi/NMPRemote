//
//  ALiRTSPSession.h
//  NMPRemote
//
//  Created by Marc Gandillon on 19.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSatipServer.h"
#import "ALiRTCPSocket.h"

@class ALiRTSPSession;

@protocol ALiRTSPSessionDelegate <NSObject>
- (void)error:(NSString *)errorMessage;
@end

@interface ALiRTSPSession : NSObject <NSStreamDelegate, AliRTCPSocketDelegate>

@property (nonatomic, weak) id <ALiRTSPSessionDelegate> delegate;
@property (nonatomic, copy) ALiSatipServer *server;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) BOOL unicast;
@property (nonatomic, assign) unsigned short rtpClientPort;
@property (nonatomic, assign) unsigned short rtcpClientPort;

- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url;
- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url
       rtpClientPort:(unsigned short)rtpClientPort
      rtcpClientPort:(unsigned short)rtcpClientPort
             unicast:(BOOL)unicast;

- (void)initNetworkCommunication;

- (void)setup;
- (void)setup:(NSString *)url;
- (void)play;
- (void)play:(NSString *)url;
- (void)options;
- (void)teardown;
- (void)describe;

- (NSDictionary *)parseRTSPAnswer:(NSString *)answer;

@end
