//
//  ALiPmtHandler.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPmtHandler.h"

@implementation ALiPmtHandler
{
    BOOL triggered;
    UInt16 programInfoLength;
}

- (id)initWithProgramNumber:(const UInt16)programNumber
{
    self = [super init];
    super.pidHandlerDelegate = self;
    _delegate = nil;
    
    // Init elementary streams dictionary
    _elementaryStreams = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Init program number
    _programNumber = programNumber;
    
    // Init triggered
    triggered = false;
    
    return self;
}

- (BOOL)triggered
{
    return triggered;
}

#pragma mark - Pid Handler Delegate

- (void)discontinuity
{
    [_delegate discontinuity:self];
}

- (void)parseTable:(ALiSection *)section
{
    if (section.tableID != 0x02)
        return;
    
    UInt16 available = section.payloadSize;
    UInt16 index = 0;
    bool changed = false;
    
    // The PMT handler has been triggered
    triggered = true;

    // If current next indicator is false then data has changed
    changed = !section.currentNextIndicator;
    
    // Check PMT PID
    NSAssert(_programNumber == section.serviceID, @"Program number does not match the service ID");

    // Capture and check Version
    checkChanged(_versionNumber, section.versionNumber, changed);
    
    // Capture PCR PID and program info length
    _pcrPid = (((UInt16)section.payload[0] & 0x1F) << 8) | ((UInt16)section.payload[1] & 0xFF);
    programInfoLength = (((UInt16)section.payload[2] & 0x0F) << 8) | ((UInt16)section.payload[3] & 0xFF);
    
    // Check for descriptors
    if (programInfoLength) {
    }
    
    // Increment bytes left counter and index
    index += programInfoLength + 4;
    available -= programInfoLength + 4;

    // Capture all elementary stream mentioned in pmt
    NSSet *set = [_elementaryStreams keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return YES;
    }];
    NSMutableArray *elementaryStreamsPIDs = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    while (available > 4) {
        //        qDebug() << "PMT: Bytes left" << available;
        UInt8 type = section.payload[index];
        UInt16 pid = (((UInt16)section.payload[index + 1] & 0x1F) << 8) | ((UInt16)section.payload[index + 2] & 0xFF);
        UInt16 esInfoLength = (((UInt16)section.payload[index + 3] & 0x0F) << 8) | ((UInt16)section.payload[index + 4] & 0xFF);
        
        // Check for descriptors
        if (esInfoLength) {
        }
        
        if (esInfoLength + 5 > available) {
            NSLog(@"This should never happen!");
        }
        
        // Increment bytes left counter and index
        index += esInfoLength + 5;
        available -= esInfoLength + 5;

        if ([_elementaryStreams objectForKey:[NSNumber numberWithUnsignedShort:pid]] == nil) {
            ALiPmtElementaryStream *es = [[ALiPmtElementaryStream alloc] initWithPid:pid andType:type];
            [_elementaryStreams setObject:es forKey:[NSNumber numberWithUnsignedShort:pid]];
            changed = true;
        }
        [elementaryStreamsPIDs removeObject:[NSNumber numberWithUnsignedShort:pid]];
    }
    
    // Check that all the elementary streams previously discovered are still present
    if ([elementaryStreamsPIDs count]) {
        changed = true;
        for (NSNumber *elementaryStreamsPID in elementaryStreamsPIDs) {
            [_elementaryStreams removeObjectForKey:elementaryStreamsPID];
        }
    }

    // Notify delegate that an SDT has been found
    if (changed) {
        [_delegate foundPMT:self];
    }
}
@end
