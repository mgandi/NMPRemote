//
//  ALiPmtElementaryStream.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPmtElementaryStream.h"

@implementation ALiPmtElementaryStream

- (id)initWithPid:(const UInt16)pid andType:(const UInt16)type
{
    _pid = pid;
    _type = type;
    return self;
}

- (BOOL)containsVideo
{
    switch (_type) {
        case 0x01:
        case 0x02:
        case 0x1B:
            return YES;
    }
    
    return NO;
}

- (BOOL)containsAudio
{
    switch (_type) {
        case 0x03:
        case 0x04:
        case 0x0F:
        case 0x11:
            return YES;
    }
    
    return NO;
}

@end
