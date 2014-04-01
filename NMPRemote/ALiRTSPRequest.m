//
//  ALiRTSPRequest.m
//  NMPRemote
//
//  Created by Abilis Systems on 31/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiRTSPRequest.h"

@implementation ALiRTSPRequest

- (id)initWithType:(MessageTypes)type request:(NSString *)request andCseq:(NSUInteger)cseq
{
    _type = type;
    _request = request;
    _cseq = cseq;
    return self;
}

@end
