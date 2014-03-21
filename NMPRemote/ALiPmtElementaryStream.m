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

@end
