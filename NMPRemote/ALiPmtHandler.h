//
//  ALiPmtHandler.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPidHandler.h"
#import "ALiPmtElementaryStream.h"

@class ALiPmtHandler;

@protocol ALiPmtHandlerDelegate <NSObject>
- (void)foundPMT:(ALiPmtHandler *)pmtHandler;
@end

@interface ALiPmtHandler : ALiPidHandler  <ALiPidHandlerDelegate>

@property (nonatomic, weak) id <ALiPmtHandlerDelegate> delegate;
@property (nonatomic, assign, readonly) UInt16 programNumber;
@property (nonatomic, assign, readonly) UInt8 versionNumber;
@property (nonatomic, assign, readonly) UInt16 pcrPid;
@property (nonatomic, copy, readonly) NSMutableDictionary *elementaryStreams;

- (id)initWithProgramNumber:(const UInt16)programNumber;
//- (BOOL)contains:(ALiElementaryStream *)elementaryStream;
- (BOOL)triggered;

@end
