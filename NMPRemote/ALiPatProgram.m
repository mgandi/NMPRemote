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

@end
