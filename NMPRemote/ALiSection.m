//
//  ALiSection.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSection.h"

@implementation ALiSection

- (id)init
{
    _data = [[NSMutableData alloc] initWithCapacity:0];
    _need = 3;
    _headerComplete = NO;
    _index = 0;
    _validCRC = NO;
    _sectionLength = 0;
    return self;
}

@end
