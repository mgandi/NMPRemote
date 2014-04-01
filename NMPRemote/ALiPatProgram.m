//
//  ALiPatProgram.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPatProgram.h"

@implementation ALiPatProgram

- (id)initWithPid:(const UInt16)pid andNumber:(const UInt16)number
{
    _pid = pid;
    _number = number;
    return self;
}

- (UInt32)uid
{
    UInt32 number = (((UInt32)_number) << 16) & 0xFFFF0000;
    UInt32 pid = (((UInt32)_pid) << 0) & 0x0000FFFF;
    return (number | pid);
}

@end
