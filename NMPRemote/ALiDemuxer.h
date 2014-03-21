//
//  ALiDemuxer.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiPidHandler.h"

@interface ALiDemuxer : NSObject

- (void)addPidHandler:(const UInt16)pid handler:(ALiPidHandler *)handler;
- (void)removePidHandlerWithPid:(const UInt16)pid;
- (void)removePidHandler:(ALiPidHandler *)handler;
- (void)removeAllPidHandlers;
- (void)push:(NSArray *)packets;

@end
