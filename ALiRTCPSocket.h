//
//  ALiRTCPSocket.h
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "ALiRTCPReport.h"

@class ALiRTCPSocket;

@protocol AliRTCPSocketDelegate <NSObject>
- (void)reportAvailable:(ALiRTCPSocket *)rtcpSocket report:(ALiRTCPReport *)erport;
@end

@interface ALiRTCPSocket : NSObject

@property (nonatomic, weak) id <AliRTCPSocketDelegate> delegate;
@property (nonatomic, copy) GCDAsyncUdpSocket *socket;

- (id) initWithPort:(UInt16)port;

- (void)parse:(NSData *)data;
- (BOOL)next:(const UInt8 **)ptr remaining:(NSUInteger *)remaining;
- (BOOL)isSR:(const UInt8 *)ptr remaining:(NSUInteger)remaining;
- (BOOL)isAPP:(const UInt8 *)ptr remaining:(NSUInteger)remaining;

@end
