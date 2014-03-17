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
    GCDAsyncUdpSocket *udpSocket;
}

- (id)init
{
    NSError *error;
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    [udpSocket bindToPort:1900 error:nil];
    if (![udpSocket joinMulticastGroup:@"239.255.255.250" error:&error]) {
        NSLog(@"Failed joining multicast group: %@", error);
    }
    /*BOOL res =*/ [udpSocket beginReceiving:nil];
    
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
    NSString *name = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *addr = [[GCDAsyncUdpSocket class] hostFromAddress:address];
    NSLog(@"didReceiveData %@ from address %@", name, addr);
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose %@", [error helpAnchor]);
}

@end
