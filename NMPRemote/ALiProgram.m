//
//  ALiProgram.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiProgram.h"
#import "ALiPmtElementaryStream.h"

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

- (NSString *)urlWithScheme:(NSString *)scheme
                       host:(NSString *)host
{
    NSMutableString *url = [NSMutableString stringWithString:@""];
    
    
    // Create list of PIDS
    NSMutableArray *pids = [[NSMutableArray alloc] initWithCapacity:0];
    [pids addObject:@"0"];
    
    // The default pids ...
    [pids addObject:@"16"];
    [pids addObject:@"17"];
    [pids addObject:@"18"];
    [pids addObject:@"20"];
    
    // ... plus the stream pids
    for (NSNumber *key in _elementaryStreams) {
        ALiPmtElementaryStream *es = [_elementaryStreams objectForKey:key];
        [pids addObject:[NSString stringWithFormat:@"%d", es.pid]];
    }
    
    // Set url scheme
    [url appendFormat:@"%@://", scheme];
    
    // Set IP address
    [url appendString:host];
    
    // Set path
    [url appendString:@"/"];
    
    // Set url query
    [url appendString:@"?"];
    [url appendFormat:@"freq=%f", _frequency];
    [url appendString:@"&msys=dvbt"];
    [url appendFormat:@"&bw=%d", _bandwidth];
    [url appendFormat:@"&pids=%@", [pids componentsJoinedByString:@","]];
    
    //    NSLog(@"URL: %@", url);
    
    return url;
}

- (BOOL)containsVideo
{
    for (NSNumber *key in _elementaryStreams) {
        ALiPmtElementaryStream *es = [_elementaryStreams objectForKey:key];
        if ([es containsVideo])
            return YES;
    }
    
    return NO;
}

- (BOOL)containsAudio
{
    for (NSNumber *key in _elementaryStreams) {
        ALiPmtElementaryStream *es = [_elementaryStreams objectForKey:key];
        if ([es containsAudio])
            return YES;
    }
    
    return NO;
}

- (UInt32)uid
{
    UInt32 number = (((UInt32)_number) << 16) & 0xFFFF0000;
    UInt32 pid = (((UInt32)_pid) << 0) & 0x0000FFFF;
    return (number | pid);
}

@end
