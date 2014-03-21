//
//  ALiSdtHandler.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSdtHandler.h"

@implementation ALiSdtHandler

- (id)initWithWhichTs:(WhichTS)whichTs
{
    self = [super init];
    super.pidHandlerDelegate = self;
    _delegate = nil;
    
    // Init services dictionary
    _services = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    // Init which TS
    _whichTs = whichTs;
    
    return self;
}

#pragma mark - Pid Handler Delegate

- (void)discontinuity
{
    [_delegate discontinuity:self];
}

- (void)dumpDescriptorFrom:(const UInt8 *)payload
                  withSize:(const UInt16)payloadSize
assignServiceProviderNameTo:(NSString **)provider
       assignServiceNameTo:(NSString **)name
{
    UInt16 index = 0;
    
    while (index < payloadSize) {
        UInt8 tag = payload[index++];
        UInt8 length = payload[index++]; // Must keep this line even though length is never used since index is incremented
        switch (tag) {
            case 0x48: {
                UInt8 type = payload[index++]; // Must keep this line even though type is never used since index is incremented
                UInt8 serviceProviderNameLength = payload[index++];
                const UInt8 *serviceProviderName = &payload[index];
                index += serviceProviderNameLength;
                *provider = [[NSString alloc] initWithBytes:(const void *)serviceProviderName
                                                     length:serviceProviderNameLength
                                                   encoding:NSASCIIStringEncoding];
                UInt8 serviceNamelength = payload[index++];
                const UInt8 *serviceName = &payload[index];
                index += serviceNamelength;
                *name = [[NSString alloc] initWithBytes:(const void *)serviceName
                                                 length:serviceNamelength
                                               encoding:NSASCIIStringEncoding];
                break;
            }
        }
    }
}

- (void)parseTable:(ALiSection *)section
{
    if (section.tableID != _whichTs)
        return;
    
    UInt16 available = section.payloadSize;
    UInt16 index = 0;
    bool changed = false;
    
    // If current next indicator is false then data has changed
    changed = !section.currentNextIndicator;
    
    // Capture and check Version
    checkChanged(_versionNumber, section.versionNumber, changed);
    
    // Capture original network ID
    _originalNetworkID = (((UInt16)section.payload[0] & 0xFF) << 8) | ((UInt16)section.payload[1] & 0xFF);
    index += 3;
    available -= 3;
    
    // Capture data about all services mentioned in SDT
    NSSet *set = [_services keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
        return YES;
    }];
    NSMutableArray *serviceIDs = [[NSMutableArray alloc] initWithArray:[set allObjects]];
    while (available > 4) {
//        NSLog(@"SDT: Bytes left %s", available);
        UInt16 serviceID = (((UInt16)section.payload[index] & 0xFF) << 8) | ((UInt16)section.payload[index + 1] & 0xFF);
//        UInt8 eitScheduleFlag = (section.payload[index + 2] & 0x02) >> 1;
//        UInt8 eitPresentFollowingFlag = (section.payload[index + 2] & 0x01);
        UInt8 runingStatus = (section.payload[index + 3] & 0xE0) >> 5;
        UInt8 freeCAMode = (section.payload[index + 3] & 0x10) >> 4;
        UInt16 descriptorLoopLength = (((UInt16)section.payload[index + 3] & 0x0F) << 8) | ((UInt16)section.payload[index + 4] & 0xFF);

        // Increment bytes left counter and index
        index += 5;
        available -= 5;

        // Check that descriptor loop length is not greater than the number of bytes left
        if (descriptorLoopLength > available) {
            NSLog(@"This is not yet implemented!");
        }

        // Create corresponding SDT Service
        if ([_services objectForKey:[NSNumber numberWithUnsignedShort:serviceID]] == nil) {
            NSString *serviceProviderName = 0, *serviceName = 0;
            
            // Dump descriptors
            if (descriptorLoopLength)
                [self dumpDescriptorFrom:(const UInt8 *)&section.payload[index]
                                withSize:descriptorLoopLength
             assignServiceProviderNameTo:&serviceProviderName
                     assignServiceNameTo:&serviceName];

            ALiSdtService *service = [[ALiSdtService alloc] initWithServiceID:serviceID
                                                                 runingStatus:(const RuningStatus)runingStatus
                                                          serviceProviderName:serviceProviderName
                                                                  serviceName:serviceName
                                                                    scrambled:(freeCAMode != 0)];
            [_services setObject:service forKey:[NSNumber numberWithUnsignedShort:serviceID]];
            changed = true;
        }
        [serviceIDs removeObject:[NSNumber numberWithUnsignedShort:serviceID]];
        
        // Incerment bytes left counter and index
        index += descriptorLoopLength;
        available -= descriptorLoopLength;
    }

    // Notify delegate that an SDT has been found
    if (changed) {
        [_delegate foundSDT:self];
    }
}

@end
