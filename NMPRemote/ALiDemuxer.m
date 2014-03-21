//
//  ALiDemuxer.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDemuxer.h"

@implementation ALiDemuxer
{
    NSMutableDictionary *handlers;
}

- (id)init
{
    // Init handlers array
    handlers = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    return self;
}

- (void)addPidHandler:(const UInt16)pid handler:(ALiPidHandler *)handler
{
    [handlers setObject:handler forKey:[NSNumber numberWithUnsignedShort:pid]];
}

- (void)removePidHandlerWithPid:(const UInt16)pid
{
    [handlers removeObjectForKey:[NSNumber numberWithUnsignedShort:pid]];
}

- (void)removePidHandler:(ALiPidHandler *)handler
{
}

- (void)removeAllPidHandlers
{
    [handlers removeAllObjects];
}

- (void)push:(NSArray *)packets
{
    for (NSData *packet in packets) {
        const UInt8 *data = (const UInt8 *)[packet bytes];
        UInt16 pid = (((UInt16)data[1] & 0x1F) << 8) | ((UInt16)data[2] & 0xFF);
        ALiPidHandler *handler = [handlers objectForKey:[NSNumber numberWithUnsignedShort:pid]];
        if (handler != nil)
            [handler push:packet];
    }
}

@end
