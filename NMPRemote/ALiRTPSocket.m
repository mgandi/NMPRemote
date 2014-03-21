//
//  ALiRTPSocket.m
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiRTPSocket.h"
#import <dispatch/dispatch.h>

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

@implementation ALiRTPSocket
{
    dispatch_queue_t rtcpQueue;
    
    UInt32 ssrc;
    UInt16 packetCount;
    UInt64 packetsLost;
    UInt16 lastSequenceNumber;
}

- (id) initWithPort:(UInt16)port
{
    // Initialize dispatch queue
    rtcpQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
    
    // Initialize RTCP socket
    _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:rtcpQueue];
    [_socket bindToPort:port error:nil];
    /*BOOL res =*/ [_socket beginReceiving:nil];
    
    // Init ssrc
    ssrc = 0;
    
    // Init last sequence nunmber
    lastSequenceNumber = 0;
    
    return self;
}

- (void)parse:(NSData *)data
{
    RtpHeader *header = (RtpHeader *)[data bytes];
    
    // Check SSRC
    if (ssrc == 0) {
        ssrc = header->ssrc;
    } else if (ssrc != header->ssrc) {
        // ...
    }
    
    // Increment packet count
    ++packetCount;
    
    // Check sequence number
    UInt16 sn = CFSwapInt16BigToHost(header->sn);
    if (lastSequenceNumber != sn) {
        UInt64 instantPacketLoss = (sn < lastSequenceNumber ? (65535 + ((UInt32) sn)) : (sn - lastSequenceNumber));
        packetsLost += instantPacketLoss;
        lastSequenceNumber = sn;
    }
    ++lastSequenceNumber;
    
    // Extract pointer to payload
    const void *ptr = ((const void *)header) + 12;
    NSInteger remaining = [data length] - 12;
    
    NSMutableArray *packets = [[NSMutableArray alloc] initWithCapacity:0];
    while (remaining >= 188) {
        [packets addObject:[[NSData alloc] initWithBytes:ptr length:188]];
        ptr += 188;
        remaining -= 188;
    }
    
//    NSLog(@"%d", CFSwapInt16BigToHost(header->sn));
    
    // Notify delegate about packets available
    if ([packets count])
        [_delegate packetsAvailable:self packets:packets ssrc:ssrc];
}

#pragma mark - GCDAsyncUdpSocket delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //    NSLog(@"didReceiveData on RTCP socket");
    [self parse:data];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", [error helpAnchor]);
}

@end
