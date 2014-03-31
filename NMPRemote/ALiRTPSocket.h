//
//  ALiRTPSocket.h
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

typedef struct {
    UInt8 cc:4;
    UInt8 x:1;
    UInt8 p:1;
    UInt8 version:2;
    
    UInt8 type:7;
    UInt8 m:1;
    
    UInt16 sn;
    
    UInt32 ts;
    UInt32 ssrc;
    UInt32 csrc;
} RtpHeader;

@class ALiRTPSocket;

@protocol ALiRTPSocketDelegate <NSObject>
- (void)packetsAvailable:(ALiRTPSocket *)socket packets:(NSArray *)packets header:(const RtpHeader *)header;
@end

@interface ALiRTPSocket : NSObject

@property (nonatomic, weak) id <ALiRTPSocketDelegate> delegate;
@property (nonatomic, copy) GCDAsyncUdpSocket *socket;

- (id) initWithPort:(UInt16)port;
- (id) initWithPort:(UInt16)port andProcessingQueue:(dispatch_queue_t)processingQueue;
- (id) initWithPort:(UInt16)port andDelegateQueue:(dispatch_queue_t)delegateQueue;
- (id) initWithPort:(UInt16)port processingQueue:(dispatch_queue_t)processingQueue andDelegateQueue:(dispatch_queue_t)delegateQueue;

- (void)parse:(NSData *)data;

@end
