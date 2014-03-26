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

@protocol ALiRTCPSocketDelegate <NSObject>
- (void)reportAvailable:(ALiRTCPSocket *)rtcpSocket report:(ALiRTCPReport *)erport;
@end

@interface ALiRTCPSocket : NSObject

@property (nonatomic, weak) id <ALiRTCPSocketDelegate> delegate;
@property (nonatomic, copy) GCDAsyncUdpSocket *socket;

- (id) initWithPort:(UInt16)port;
- (id) initWithPort:(UInt16)port andProcessingQueue:(dispatch_queue_t)processingQueue;
- (id) initWithPort:(UInt16)port andDelegateQueue:(dispatch_queue_t)delegateQueue;
- (id) initWithPort:(UInt16)port processingQueue:(dispatch_queue_t)processingQueue andDelegateQueue:(dispatch_queue_t)delegateQueue;

- (void)parse:(NSData *)data;
- (BOOL)next:(const UInt8 **)ptr remaining:(NSUInteger *)remaining;
- (BOOL)isSR:(const UInt8 *)ptr remaining:(NSUInteger)remaining;
- (BOOL)isAPP:(const UInt8 *)ptr remaining:(NSUInteger)remaining;

@end
