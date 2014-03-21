//
//  ALiProgram.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiProgram.h"

@implementation ALiProgram

- (id)initWithFrequency:(const double)frequency
              bandwidth:(const UInt8)bandwidth
                   tsId:(const UInt16)tsID
                 number:(const UInt16)number
                    pid:(const UInt16)pid
{
    _frequency = frequency;
    _bandwidth = bandwidth;
    _tsID = tsID;
    _number = number;
    _pid = pid;
    _elementaryStreams = [[NSMutableDictionary alloc] initWithCapacity:0];
    return self;
}

@end
