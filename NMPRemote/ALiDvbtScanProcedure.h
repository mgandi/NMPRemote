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

@class ALiDvbtScanProcedure;

@protocol ALiDvbtScanProcedureDelegate <NSObject>
- (void)done:(ALiDvbtScanProcedure *)procedure;
@end

@interface ALiDvbtScanProcedure : NSObject <ALiRTSPSessionDelegate, ALiRTCPSocketDelegate, ALiRTPSocketDelegate, ALiPatHandlerDelegate, ALiSdtHandlerDelegate, ALiPmtHandlerDelegate>

@property (nonatomic, weak) id <ALiDvbtScanProcedureDelegate> delegate;
@property (nonatomic, readonly, copy) ALiSatipServer *server;
@property (nonatomic, readonly, assign) double startFrequency;
@property (nonatomic, readonly, assign) double stepFrequency;
@property (nonatomic, readonly, assign) double stopFrequency;

- (id)initWithServer:(ALiSatipServer *)server
      startFrequency:(double)startFrequency
       stepFrequency:(double)stepFrequency
       stopFrequency:(double)stopFrequency;

- (void)start;
- (void)stop;
- (void)step;

@end
