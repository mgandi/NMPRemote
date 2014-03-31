//
//  ALiRTSPRequest.m
//  NMPRemote
//
//  Created by Abilis Systems on 31/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiRTSPRequest.h"

@implementation ALiRTSPRequest

- (id)initWithType:(MessageTypes)type andRequest:(NSString *)request
{
    _type = type;
    _request = request;
    return self;
}

@end
