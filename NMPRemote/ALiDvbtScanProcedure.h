//
//  ALiDvbtScanProcedure.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSatipServer.h"
#import "ALiRTSPSession.h"
#import "ALiPatHandler.h"
#import "ALiSdtHandler.h"
#import "ALiPmtHandler.h"
#import "ALiProgram.h"

@class ALiDvbtScanProcedure;

@protocol ALiDvbtScanProcedureDelegate <NSObject>
- (void)done:(ALiDvbtScanProcedure *)procedure;
- (void)foundProgram:(ALiProgram *)program;
@end

@interface ALiDvbtScanProcedure : NSObject <ALiRTSPSessionDelegate, ALiRTCPSocketDelegate, ALiRTPSocketDelegate, ALiPatHandlerDelegate, ALiSdtHandlerDelegate, ALiPmtHandlerDelegate>

@property (nonatomic, weak) id <ALiDvbtScanProcedureDelegate> delegate;
@property (nonatomic, readonly, copy) ALiSatipServer *server;
@property (nonatomic, readonly, assign) double startFrequency;
@property (nonatomic, readonly, assign) double stepFrequency;
@property (nonatomic, readonly, assign) double stopFrequency;
@property (atomic, readonly, assign) UInt8 stepStatus;

- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency;
- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency
     processingQueue:(dispatch_queue_t)processingQueue;

- (void)start;
- (void)stop;
- (void)step;

@end
