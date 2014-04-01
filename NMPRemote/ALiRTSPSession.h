//
//  ALiRTSPSession.h
//  NMPRemote
//
//  Created by Marc Gandillon on 19.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSatipServer.h"
#import "ALiRTCPSocket.h"
#import "ALiRTPSocket.h"

typedef enum {
    IDLE = 0,
    SET = 1,
    PLAYING = 2
} Status;

@class ALiRTSPSession;

@protocol ALiRTSPSessionDelegate <NSObject>
- (void)sessionSetup:(ALiRTSPSession *)session;
- (void)sessionPlaying:(ALiRTSPSession *)session;
- (void)sessionOptionsDone:(ALiRTSPSession *)session;
- (void)sessionTeardowned:(ALiRTSPSession *)session;
- (void)error:(NSString *)errorMessage;
@end

@interface ALiRTSPSession : NSObject <NSStreamDelegate, ALiRTCPSocketDelegate, ALiRTPSocketDelegate>

@property (nonatomic, weak) id <ALiRTSPSessionDelegate> delegate;
@property (nonatomic, copy, readonly) ALiSatipServer *server;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign, readonly) BOOL unicast;
@property (nonatomic, assign, readonly) unsigned short rtpClientPort;
@property (nonatomic, assign, readonly) unsigned short rtcpClientPort;
@property (nonatomic, assign) Status status;

// RTSP
@property (atomic, assign, readonly) NSUInteger cseq;
@property (nonatomic, copy, readonly) NSString *sessionID;
@property (nonatomic, assign, readonly) NSUInteger sessionTimeout;
@property (nonatomic, assign, readonly) NSUInteger streamID;

// Loop control
@property (atomic, assign, readonly) BOOL running, waitingAnswer;

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url;
- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate;
- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
       rtpClientPort:(unsigned short)rtpClientPort
      rtcpClientPort:(unsigned short)rtcpClientPort
             unicast:(BOOL)unicast;

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue;
- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate;
- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
       rtpClientPort:(unsigned short)rtpClientPort
      rtcpClientPort:(unsigned short)rtcpClientPort
             unicast:(BOOL)unicast;

- (void)setup;
- (void)setup:(NSString *)url;
- (void)play;
- (void)play:(NSString *)url;
- (void)options;
- (void)teardown;
- (void)describe;

- (void)pauseReception;
- (void)pauseRTCPReception;
- (void)pauseRTPReception;
- (void)resumeReception;
- (void)resumeRTCPReception;
- (void)resumeRTPReception;

@end
