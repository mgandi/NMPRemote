//
//  ALiSdtHandler.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPidHandler.h"
#import "ALiSdtService.h"

typedef enum {
    CurrentTs = 0x42,
    OtherTs   = 0x46
} WhichTS;

@class ALiSdtHandler;

@protocol ALiSdtHandlerDelegate <NSObject>
- (void)discontinuity:(ALiPidHandler *)pidhandler;
- (void)foundSDT:(ALiSdtHandler *)sdtHandler;
@end

@interface ALiSdtHandler : ALiPidHandler  <ALiPidHandlerDelegate>

@property (nonatomic, weak) id <ALiSdtHandlerDelegate> delegate;
@property (nonatomic, assign, readonly) WhichTS whichTs;
@property (nonatomic, assign, readonly) UInt16 originalNetworkID;
@property (nonatomic, assign, readonly) UInt8 versionNumber;
@property (nonatomic, copy, readonly) NSMutableDictionary *services;

- (id)initWithWhichTs:(WhichTS)whichTs;

@end
