//
//  ALiRTCPSocket.m
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiRTCPSocket.h"
#import "ALiRTCPReport.h"
#import <dispatch/dispatch.h>

enum RtcpType {
    RTCP_SR   = 200,
    RTCP_RR   = 201,
    RTCP_SDES = 202,
    RTCP_BYE  = 203,
    RTCP_APP  = 204
};

typedef struct {
    UInt8 subtype:5;
    UInt8 padbit:1;
    UInt8 version:2;
    UInt8 type;

    UInt16 length;
} RtcpCommonHeader;


typedef struct {
    UInt32 ntp_timestamp_msw;
    UInt32 ntp_timestamp_lsw;
    UInt32 rtp_timestamp;
    UInt32 senders_packet_count;
    UInt32 senders_octet_count;
} SenderInfo;
 
typedef struct {
    RtcpCommonHeader header;
    UInt32 ssrc;
    SenderInfo si;
} RtcpSR;
 
typedef struct {
    RtcpCommonHeader header;
    UInt32 ssrc;
    char name[4];
    UInt16 identifier;
    UInt16 string_length;
    char string[];
} RtcpAPP;

@implementation ALiRTCPSocket
{
    dispatch_queue_t rtcpQueue;
}

- (id) initWithPort:(UInt16)port
{
    // Initialize dispatch queue
    rtcpQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
    
    // Initialize RTCP socket
    _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:rtcpQueue];
    [_socket bindToPort:port error:nil];
    /*BOOL res =*/ [_socket beginReceiving:nil];
    
    return self;
}

- (void)parse:(NSData *)data
{
    const void *ptr = [data bytes];
    NSUInteger remaining = [data length];
    ALiRTCPReport *report = [[ALiRTCPReport alloc] init];
    
    // Loop through all data structures and extract relevant information
    do {
        
        if ([self isSR:ptr remaining:remaining]) {
            RtcpSR *sr = (RtcpSR *)ptr;
            report.packetCount = CFSwapInt32BigToHost(sr->si.senders_packet_count);
        }
        
        else if ([self isAPP:ptr remaining:remaining]) {
            RtcpAPP *app = (RtcpAPP *)ptr;
            report.ssrc = app->ssrc;
            
            NSString *content = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)app->string length:app->string_length]
                                                      encoding:NSASCIIStringEncoding];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ver=(.*);tuner=(.*);pids=(.*)"
                                                                                    options:0
                                                                                      error:nil];
            NSTextCheckingResult *match = [regex firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
            if (match != nil) {
                NSMutableDictionary *arguments = [[NSMutableDictionary alloc] initWithCapacity:0];
                [arguments setObject:[content substringWithRange:[match rangeAtIndex:1]] forKey:@"ver"];
                [arguments setObject:[content substringWithRange:[match rangeAtIndex:2]] forKey:@"tuner"];
                [arguments setObject:[content substringWithRange:[match rangeAtIndex:3]] forKey:@"pids"];
                report.arguments = arguments;
            }
        }
        
    } while([self next:(const UInt8 **)&ptr remaining:&remaining]);
    
    // Publish reformated report
    [_delegate reportAvailable:self report:report];
}

- (BOOL)next:(const UInt8 **)ptr remaining:(NSUInteger *)remaining
{
    UInt16 size = (CFSwapInt16BigToHost(((RtcpCommonHeader *)*ptr)->length) + 1) * sizeof(UInt32);
    
    // Test if remaining bytes are enough to hold the structure
    if (*remaining < size)
        return false;
    
    // Increment data pointer and decrement remaining bytes
    *ptr += size;
    *remaining -= size;
    
    // Test if type of packet is valid
    switch (((RtcpCommonHeader *)*ptr)->type) {
        case RTCP_SR:
        case RTCP_RR:
        case RTCP_SDES:
        case RTCP_BYE:
        case RTCP_APP:
            break;
        default:
            return false;
    }
    
    return true;
}

- (BOOL)isSR:(const UInt8 *)ptr remaining:(NSUInteger)remaining
{
    UInt16 size = (CFSwapInt16BigToHost(((RtcpCommonHeader *)ptr)->length) + 1) * sizeof(UInt32);
    
    if (((RtcpCommonHeader *)ptr)->type == RTCP_SR) {
        if (remaining < size)
            return false;
        
        if (remaining < sizeof(RtcpSR))
            return false;
        
        return true;
    }
    
    return false;
}



- (BOOL)isAPP:(const UInt8 *)ptr remaining:(NSUInteger)remaining
{
    UInt16 size = (CFSwapInt16BigToHost(((RtcpCommonHeader *)ptr)->length) + 1) * sizeof(UInt32);
    
    if (((RtcpCommonHeader *)ptr)->type == RTCP_APP) {
        if (remaining < size)
            return false;
        
        if (remaining < sizeof(RtcpAPP))
            return false;
        
        return true;
    }
    
    return false;
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
