//
//  ALiSSDPClient.m
//  NMPRemote
//
//  Created by Marc Gandillon on 13.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSSDPClient.h"
#import "GCDAsyncUdpSocket.h"

@implementation ALiSSDPClient
{
    GCDAsyncUdpSocket *udpSocket, *ssdpSocket;
}

- (id)init
{
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    [udpSocket bindToPort:0 error:nil];
    /*BOOL res =*/ [udpSocket beginReceiving:nil];
    
    ssdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [ssdpSocket enableBroadcast:YES error:nil];
    [ssdpSocket bindToPort:1900 error:nil];
    [ssdpSocket joinMulticastGroup:@"239.255.255.250" error:nil];
    /*BOOL res =*/ [ssdpSocket beginReceiving:nil];
    
    return self;
}

- (void)searchForDevices:(NSString *)urn
{
    NSString *request = [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\n"\
                                                    "HOST: 239.255.255.250:1900\r\n"\
                                                    "ST: %@\r\n"\
                                                    "MAN: \"ssdp:discover\"\r\n"\
                                                    "USER-AGENT: Platform/1.1 UPnP/1.1 BREngine/0.1\r\n"
                                                    "MX: 2\r\n\r\n", urn];
    [udpSocket sendData:[request dataUsingEncoding:NSASCIIStringEncoding]
                 toHost:@"239.255.255.250"
                   port:1900
            withTimeout:-1
                    tag:2];
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
    // Extract received data
    NSString *dat = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    // Allocate new device resource
    ALiSSDPDevice *device = [[ALiSSDPDevice alloc] init];
    
    // Check if the received message is an SSDP search response or an SSDP notify
    if ([dat hasPrefix:@"HTTP/1.1 200 OK"]) {
        device.requestLine = @"HTTP/1.1 200 OK";
    } else if ([dat hasPrefix:@"NOTIFY * HTTP/1.1"]) {
        device.requestLine = @"NOTIFY * HTTP/1.1";
    } else {
        return;
    }
    
    // Make NSDictionnary of header fields
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:0];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\w.-]+):\\s?(.*)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    [regex enumerateMatchesInString:dat options:0 range:NSMakeRange(0, [dat length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        [arguments setObject:[dat substringWithRange:[match rangeAtIndex:2]] forKey:[dat substringWithRange:[match rangeAtIndex:1]]];
    }];
    
    // Populate device resource and call appropriate callback
    device.address = [[GCDAsyncUdpSocket class] hostFromAddress:address];
    device.arguments = arguments;
    if ([device.requestLine isEqualToString:@"NOTIFY * HTTP/1.1"]) {
        device.nts = [arguments objectForKey:@"NTS"];
        if ([device.nts isEqualToString:@"ssdp:alive"]) {
            device.urn = [arguments objectForKey:@"NT"];
            [_delegate SSDPDeviceJoin:self device:device];
        } else if ([device.nts isEqualToString:@"ssdp:byebye"]) {
            device.urn = [arguments objectForKey:@"NT"];
            [_delegate SSDPDeviceLeft:self device:device];
        }
    } else if ([device.requestLine isEqualToString:@"HTTP/1.1 200 OK"]) {
        device.urn = [arguments objectForKey:@"ST"];
        [_delegate foundSSDPDevice:self device:device];
    }
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", [error helpAnchor]);
}

@end
