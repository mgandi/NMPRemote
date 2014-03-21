//
//  ALiPatHandler.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPatHandler.h"

@implementation ALiPatHandler

- (id)init
{
    self = [super init];
    super.pidHandlerDelegate = self;
    _delegate = nil;
    
    // Init programs dictionary
    _programs = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    return self;
}

#pragma mark - Pid Handler Delegate

- (void)discontinuity
{
    [_delegate discontinuity:self];
}

- (void)parseTable:(ALiSection *)section
{
    if (section.tableID != 0x0)
        return;
    
    UInt16 available = section.payloadSize;
    UInt16 index = 0;
    bool changed = false;
    
    // If current next indicator is false then data has changed
    changed = !section.currentNextIndicator;
    
    // Capture and check Version
    checkChanged(_versionNumber, section.versionNumber, changed);
    
    // Capture all programs mentioned in pat
    NSSet *set = [_programs keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return YES;
    }];
    NSMutableArray *programNumbers = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    while (available > 4) {
        UInt16 programNumber = CFSwapInt16(*((UInt16 *)&section.payload[index]));
        if (!programNumber) {
            _originalNetworkID = (((UInt16)section.payload[index + 2] & 0x1F) << 8) | ((UInt16)section.payload[index + 3] & 0xFF);
//            NSLog(@"Network ID: 0x%04x", _originalNetworkID);
        } else {
            UInt16 programMapPid = (((UInt16)section.payload[index + 2] & 0x1F) << 8) | ((UInt16)section.payload[index + 3] & 0xFF);
            if ([_programs objectForKey:[NSNumber numberWithUnsignedShort:programNumber]] == nil) {
                ALiPatProgram *prgm = [[ALiPatProgram alloc] initWithPid:programMapPid andNumber:programNumber];
                [_programs setObject:prgm forKey:[NSNumber numberWithUnsignedShort:programNumber]];
//                NSLog(@"Program: 0x%04x @ 0x%04x",  programNumber, programMapPid);
            }
            [programNumbers removeObject:[NSNumber numberWithUnsignedShort:programNumber]];
        }
        index += 4;
        available -= 4;
    }
    
    // Check that all the programs previously discovered are still present
    if ([programNumbers count]) {
        changed = true;
        for (NSNumber *programNumber in programNumbers) {
            [_programs removeObjectForKey:programNumber];
        }
    }
    
    // Notify delegate that a PAT has been found
    if (changed) {
        [_delegate foundPAT:self];
    }
}

@end
