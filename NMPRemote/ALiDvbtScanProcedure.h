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

typedef enum {
    SCAN_IDLE = 0,
    SCAN_START_REQUEST = 1,
    SCAN_STEP_REQUEST = 2,
    
    SCAN_STOP_REQUEST = 3,
    SCAN_TEARDOWN_REQUEST = 4,
    SCAN_TEARDOWN_DONE = 5,
    
    SCAN_SETUP_REQUEST = 6,
    SCAN_SETUP_DONE = 7,
    
    SCAN_LOCK_TIMEOUT = 10,
    SCAN_PAT_TIMEOUT = 11,
    SCAN_STEP_TIMEOUT = 12,
    
    SCAN_PLAY_REQUEST = 13,
    SCAN_PLAY_DONE = 14,
    SCAN_RX_NSTREAM = 15,
    
    SCAN_UNLOCKED = 16,
    SCAN_LOCKED = 17,
    SCAN_PAT_FOUND = 18,
    SCAN_PMT_FOUND = 19,
    SCAN_SDT_FOUND = 20,
    SCAN_STEP_COMPLETE = 21,
}ScanStatus;

@class ALiDvbtScanProcedure;

@protocol ALiDvbtScanProcedureDelegate <NSObject>
- (void)done:(ALiDvbtScanProcedure *)procedure;
- (void)stopped:(ALiDvbtScanProcedure *)procedure;
- (void)foundProgram:(ALiDvbtScanProcedure *)procedure program:(ALiProgram *)program;
@end

@interface ALiDvbtScanProcedure : NSObject <ALiRTSPSessionDelegate, ALiRTCPSocketDelegate, ALiRTPSocketDelegate, ALiPatHandlerDelegate, ALiSdtHandlerDelegate, ALiPmtHandlerDelegate>

@property (nonatomic, weak) id <ALiDvbtScanProcedureDelegate> delegate;
@property (nonatomic, readonly, copy) ALiSatipServer *server;
@property (nonatomic, readonly, assign) double startFrequency;
@property (nonatomic, readonly, assign) double stepFrequency;
@property (nonatomic, readonly, assign) double stopFrequency;
@property (atomic, readonly, assign) ScanStatus scanStatus;

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
