//
//  ALiRTPSocket.h
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

@interface ALiRTPSocket : NSObject

@property (nonatomic, copy) GCDAsyncUdpSocket *socket;

- (id) initWithPort:(UInt16)port;

- (void)parse:(NSData *)data;

@end
