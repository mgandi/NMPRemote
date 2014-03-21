//
//  ALiPatHandler.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiPidHandler.h"
#import "ALiPatProgram.h"

@class ALiPatHandler;

@protocol ALiPatHandlerDelegate <NSObject>
- (void)discontinuity:(ALiPidHandler *)pidhandler;
- (void)foundPAT:(ALiPatHandler *)pathandler;
@end

@interface ALiPatHandler : ALiPidHandler  <ALiPidHandlerDelegate>

@property (nonatomic, weak) id <ALiPatHandlerDelegate> delegate;
@property (nonatomic, assign, readonly) UInt16 originalNetworkID;
@property (nonatomic, assign, readonly) UInt8 versionNumber;
@property (nonatomic, copy, readonly) NSMutableDictionary *programs;

@end
