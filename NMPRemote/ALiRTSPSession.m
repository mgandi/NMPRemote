//
//  ALiRTSPSession.m
//  NMPRemote
//
//  Created by Marc Gandillon on 19.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiRTSPSession.h"
#import <dispatch/dispatch.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "ALiRTSPRequest.h"

@implementation ALiRTSPSession
{
    // RTSP Network
    GCDAsyncSocket *rtspSocket;
    dispatch_queue_t socketQueue, rtspProcessingQueue, rtspDelegateQueue, requestQueue;
    NSMutableData *rtspInputBuffer;
    NSMutableArray *requests;
    NSLock *runLock;
    
    // RTCP Network
    ALiRTCPSocket *rtcpSocket;
    
    // RTP Network
    ALiRTPSocket *rtpSocket;
}

- (void)initNetworkCommunication
{
    NSError *error = nil;
    
    // Create our rtspSocket GCDAsyncSocket instance.
	// Notice that we give it the normal delegate AND a delegate queue.
	// The socket will do all of its operations in a background queue,
	// and you can tell it which thread/queue to invoke your delegate on.
	rtspSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Connect to host
    if (![rtspSocket connectToHost:_server.device.address onPort:554 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
    
    // Initialize RTSP input buffer
    rtspInputBuffer = [[NSMutableData alloc] initWithCapacity:0];
    
    // Initialize RTCP socket
    rtcpSocket = [[ALiRTCPSocket alloc] initWithPort:_rtcpClientPort processingQueue:socketQueue andDelegateQueue:rtspProcessingQueue];
    _rtcpClientPort = [rtcpSocket.socket localPort];
    
    // Initialize RTP socket
    rtpSocket = [[ALiRTPSocket alloc] initWithPort:_rtpClientPort processingQueue:socketQueue andDelegateQueue:rtspProcessingQueue];
    _rtpClientPort = [rtpSocket.socket localPort];
}

- (void)initRequestQueueLoop
{
    // Init run lock
    runLock = [[NSLock alloc] init];
    
    dispatch_async(requestQueue, ^{
        // Acquire run lock
        [runLock lock];
        
        // Set status to be running
        _running = YES;
        
        // Loop...
        while (_running) {
            while ([requests count] == 0) {
                usleep(100000); // Sleep for a 100 msecs
            }
            
            // Take the first request on the top of the list and send it
            ALiRTSPRequest *request = [requests firstObject];
            
//            fprintf(stderr, "R: %lu %d\n", (unsigned long)request.cseq, request.type);
            
            // Send request
            NSData *data = [[NSData alloc] initWithData:[request.request dataUsingEncoding:NSASCIIStringEncoding]];
            [rtspSocket writeData:data withTimeout:-1.0 tag:request.type];
            
            // Start read data
            [rtspSocket readDataWithTimeout:-1 buffer:rtspInputBuffer bufferOffset:0 tag:request.type];
            _waitingAnswer = YES;
            
            // Wait for the answer to be received
            while (_waitingAnswer);
            
//            fprintf(stderr, "A: %lu %d\n", (unsigned long)request.cseq, request.type);
            
            // Remove RTSP request from the list
            [requests removeObject:request];
        }
        
        // Release run lock
        [runLock unlock];
    });
}

- (id)init
{
    return [self initWithServer:nil
                            url:@""
                  delegateQueue:0
                   rtcpDelegate:self
                    rtpDelegate:self
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
{
    return [self initWithServer:server
                            url:url
                  delegateQueue:0
                   rtcpDelegate:self
                    rtpDelegate:self
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
{
    return [self initWithServer:server
                            url:url
                  delegateQueue:0
                   rtcpDelegate:rtcpDelegate
                    rtpDelegate:rtpDelegate
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
       rtpClientPort:(unsigned short)rtpClientPort
      rtcpClientPort:(unsigned short)rtcpClientPort
             unicast:(BOOL)unicast
{
    return [self initWithServer:server
                            url:url
                  delegateQueue:0
                   rtcpDelegate:rtcpDelegate
                    rtpDelegate:rtpDelegate
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue
{
    return [self initWithServer:server
                            url:url
                  delegateQueue:delegateQueue
                   rtcpDelegate:self
                    rtpDelegate:self
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
{
    return [self initWithServer:server
                            url:url
                  delegateQueue:delegateQueue
                   rtcpDelegate:rtcpDelegate
                    rtpDelegate:rtpDelegate
                  rtpClientPort:0
                 rtcpClientPort:0
                        unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server
                 url:(NSString *)url
       delegateQueue:(dispatch_queue_t)delegateQueue
        rtcpDelegate:(id <ALiRTCPSocketDelegate>)rtcpDelegate
         rtpDelegate:(id <ALiRTPSocketDelegate>)rtpDelegate
       rtpClientPort:(unsigned short)rtpClientPort
      rtcpClientPort:(unsigned short)rtcpClientPort
             unicast:(BOOL)unicast
{
    // Set status
    _status = IDLE;
    
    // Set server
    _server = server;
    
    // Set url
    _url = url;
    
    // Set RTP client port
    _rtpClientPort = rtpClientPort;
    
    // Set RTCP client port
    _rtcpClientPort = rtcpClientPort;
    
    // Set unicast
    _unicast = unicast;
    
    // Set session ID to nil
    _sessionID = nil;
    
    // Init loop control
    _running = NO;
    _waitingAnswer = NO;
    
    // Initialize dispatch queues
    if (delegateQueue != 0) {
        socketQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
        rtspDelegateQueue = delegateQueue;
        rtspProcessingQueue = delegateQueue;
    } else {
        socketQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
        rtspProcessingQueue = dispatch_queue_create("tw.com.ali.rtspProcesing", NULL);
        rtspDelegateQueue = rtspProcessingQueue;
    }
    
    // Initialize request queue
    requestQueue = dispatch_queue_create("tw.com.ali.rtspQueue", NULL);
    
    // Initialize network communication
    [self initNetworkCommunication];
    
    // Set RTCP delegate
    rtcpSocket.delegate = rtcpDelegate;
    
    // Set RTP delegate
    rtpSocket.delegate = rtpDelegate;
    
    // Init requests queue
    requests = [[NSMutableArray alloc] initWithCapacity:0];
    
    // Init request queue loop
    [self initRequestQueueLoop];

    return self;
}

- (void)dealloc
{
    _running = NO;
    
    // Wait for the run loop to end
    [runLock lock];
    [runLock unlock];
}

- (void)setup:(NSString *)url
{
    _url = url;
    [self setup];
}

- (void)setup
{
    // Get next cseq
    NSUInteger cseq = ++_cseq;
    
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"SETUP %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %lu\r\n", (unsigned long)cseq];
    [request appendFormat:@"Transport: RTP/AV;%@=%d-%d\r\n", (_unicast ? @"unicast;client_port" : @"multicast;port"), _rtpClientPort, _rtcpClientPort];
    [request appendString:@"\r\n"];
    
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++");
//    NSLog(@"\n%@", request);
    
    // Create corresponding ALiRTSPRequest and add it to the list of requests
    ALiRTSPRequest *rtsprequest = [[ALiRTSPRequest alloc] initWithType:SETUP request:request andCseq:cseq];
    [requests addObject:rtsprequest];
}

- (void)play:(NSString *)url
{
    _url = url;
    [self play];
}

- (void)play
{
    // Get next cseq
    NSUInteger cseq = ++_cseq;
    
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"PLAY %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %lu\r\n", (unsigned long)cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendString:@"\r\n"];
    
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++");
//    NSLog(@"\n%@", request);
    
    // Create corresponding ALiRTSPRequest and add it to the list of requests
    ALiRTSPRequest *rtsprequest = [[ALiRTSPRequest alloc] initWithType:PLAY request:request andCseq:cseq];
    [requests addObject:rtsprequest];
}

- (void)options
{
    // Get next cseq
    NSUInteger cseq = ++_cseq;
    
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"OPTIONS %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %lu\r\n", (unsigned long)cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendString:@"\r\n"];
    
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++");
//    NSLog(@"\n%@", request);
    
    // Create corresponding ALiRTSPRequest and add it to the list of requests
    ALiRTSPRequest *rtsprequest = [[ALiRTSPRequest alloc] initWithType:OPTIONS request:request andCseq:cseq];
    [requests addObject:rtsprequest];
}

- (void)teardown
{
    // Get next cseq
    NSUInteger cseq = ++_cseq;
    
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"TEARDOWN %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %lu\r\n", (unsigned long)cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendFormat:@"Connection: close\r\n"];
    [request appendString:@"\r\n"];
    
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++");
//    NSLog(@"\n%@", request);
    
    // Create corresponding ALiRTSPRequest and add it to the list of requests
    ALiRTSPRequest *rtsprequest = [[ALiRTSPRequest alloc] initWithType:TEARDOWN request:request andCseq:cseq];
    [requests addObject:rtsprequest];
}

- (void)describe
{
    
}

- (void)pauseReception
{
    [self pauseRTCPReception];
    [self pauseRTPReception];
}

- (void)pauseRTCPReception
{
    [rtcpSocket.socket pauseReceiving];
}

- (void)pauseRTPReception
{
    [rtpSocket.socket pauseReceiving];
}

- (void)resumeReception
{
    [self resumeRTCPReception];
    [self resumeRTPReception];
}

- (void)resumeRTCPReception
{
    [rtcpSocket.socket beginReceiving:nil];
}

- (void)resumeRTPReception
{
    [rtpSocket.socket beginReceiving:nil];
}

- (NSDictionary *)parseRTSPAnswer:(NSString *)answer withTag:(long)tag
{
    
//    NSLog(@"+++++++++++++++++++++++++++++++++++++++++");
//    NSLog(@"\n%@", answer);
    
    // Check if the received message is an RTSP answer and extract error code and error message form request line
    NSRegularExpression *regexHeader = [NSRegularExpression regularExpressionWithPattern:@"RTSP/1\\.0 (\\d+) (.*)"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSTextCheckingResult *matchHeader = [regexHeader firstMatchInString:answer options:0 range:NSMakeRange(0, [answer length])];
    if (matchHeader == nil) {
        dispatch_async(rtspDelegateQueue, ^{
            NSLog(@"This is not an RTSP message");
            [_delegate error:@"This is not an RTSP message"];
        });
        return nil;
    }
    NSUInteger errorCode = [[answer substringWithRange:[matchHeader rangeAtIndex:1]] intValue];
    NSString *errorString = [answer substringWithRange:[matchHeader rangeAtIndex:2]];
    
    // Check error code
    switch (errorCode) {
        case 200:
            break;
        default:
            NSLog(@"Apparently there is an error: %lu %@", (unsigned long)errorCode, errorString);
            break;
    }
    
    // Make NSDictionnary of header fields
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:0];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\w.-]+):\\s?(.*)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    [regex enumerateMatchesInString:answer options:0 range:NSMakeRange(0, [answer length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        [arguments setObject:[answer substringWithRange:[match rangeAtIndex:2]] forKey:[answer substringWithRange:[match rangeAtIndex:1]]];
    }];
    
    // Extract corresponding request
    ALiRTSPRequest *rtspRequest = [requests firstObject];
    
    // Check validity of tag vs request type
    if (rtspRequest.type != tag) {
        NSLog(@"Wrong tag!");
        return nil;
    }
    
    // Check validity of Cseq
    NSUInteger answerCseq = [[arguments objectForKey:@"CSeq"] intValue];
    if (rtspRequest.cseq != answerCseq) {
        NSLog(@"Wrong CSeq number!");
        return nil;
    }
    
    // We've received the answer
    _waitingAnswer = NO;
    
    return arguments;
}

#pragma mark - GCDAsynchSocket Delegate

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
//    NSLog(@"rtspSocket socket connected to: %@:%d", host, port);
}

- (void)socket:(GCDAsyncSocket *)sender didWriteDataWithTag:(long)tag
{
//    NSLog(@"rtspSocket socket wrote data with tag: %ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSDictionary *headers = [self parseRTSPAnswer:receivedString withTag:tag];
    NSString *obj;
    
    switch (tag) {
            
        case SETUP: {
//            NSLog(@"Received answer to SETUP message");
            
            // Extract session parameters
            if ((obj = [headers objectForKey:@"Session"]) != nil) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(.*);timeout=(\\d+)"
                                                                                       options:0
                                                                                         error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:obj options:0 range:NSMakeRange(0, [obj length])];
                _sessionID = [obj substringWithRange:[match rangeAtIndex:1]];
                _sessionTimeout = [[obj substringWithRange:[match rangeAtIndex:2]] intValue] / 2;
            } else {
                dispatch_async(rtspDelegateQueue, ^{
                    NSLog(@"Malformed RTSP answer for SETUP message!");
                    [_delegate error:@"Malformed RTSP answer for SETUP message!"];
                });
                return;
            }
            
            // Extract stream ID
            if ((obj = [headers objectForKey:@"com.ses.streamID"]) != nil) {
                _streamID = [obj intValue];
            } else {
                dispatch_async(rtspDelegateQueue, ^{
                    NSLog(@"Malformed RTSP answer for SETUP message!");
                    [_delegate error:@"Malformed RTSP answer for SETUP message!"];
                });
                return;
            }
            
            // Set status
            _status = SET;
            
            // Notify delegate if status change
            dispatch_async(rtspDelegateQueue, ^{
                [_delegate sessionSetup:self];
            });
            
            break;
        }
            
        case PLAY: {
//            NSLog(@"Received answer to PLAY message");
            
            // Set status
            _status = PLAYING;
            
            // Notify delegate of status change
            dispatch_async(rtspDelegateQueue, ^{
                [_delegate sessionPlaying:self];
            });
            
            break;
        }
            
        case OPTIONS: {
//            NSLog(@"Received answer to OPTIONS message");
            
            // Notify delegate if status change
            dispatch_async(rtspDelegateQueue, ^{
                [_delegate sessionOptionsDone:self];
            });
            
            break;
        }
            
        case TEARDOWN: {
//            NSLog(@"Received answer to TEARDOWN message");
            
            // Set status
            _status = IDLE;
            
            // Notify delegate of status change
            dispatch_async(rtspDelegateQueue, ^{
                [_delegate sessionTeardowned:self];
            });
            
            break;
        }
            
        case DESCRIBE:
//            NSLog(@"Received answer to DESCRIBE message");
            break;
            
    }
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sender shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
	return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sender withError:(NSError *)err
{
//    NSLog(@"rtspSocket socket disconnected");
}

#pragma mark - RTCP Socket Delegate

- (void)reportAvailable:(ALiRTCPSocket *)rtcpSocket report:(ALiRTCPReport *)report
{
}

#pragma mark - RTP Socket Delegate

- (void)packetsAvailable:(ALiRTPSocket *)socket packets:(NSArray *)packets header:(const RtpHeader *)header
{
}

@end
