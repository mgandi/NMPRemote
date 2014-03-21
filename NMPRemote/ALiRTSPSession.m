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

enum MessageTypes {
    SETUP = 1,
    PLAY = 2,
    OPTIONS = 3,
    TEARDOWN = 4,
    DESCRIBE = 5
};

@implementation ALiRTSPSession
{
    // RTSP Network
    GCDAsyncSocket *rtspSocket;
    dispatch_queue_t socketQueue;
    NSMutableData *rtspInputBuffer;
    
    // RTCP Network
    ALiRTCPSocket *rtcpSocket;
    
    // RTP Network
    ALiRTPSocket *rtpSocket;
}

- (id)init
{
    return [self initWithServer:nil
                            url:@""
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
    
    // Initialize network communication
    [self initNetworkCommunication];
    
    // Set RTCP delegate
    rtcpSocket.delegate = rtcpDelegate;
    
    // Set RTP delegate
    rtpSocket.delegate = rtpDelegate;
    
    return self;
}

- (void)initNetworkCommunication
{
    NSError *error = nil;
    
    // Initialize dispatch queue
    socketQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
    
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
    rtcpSocket = [[ALiRTCPSocket alloc] initWithPort:_rtcpClientPort];
    _rtcpClientPort = [rtcpSocket.socket localPort];
    rtcpSocket.delegate = self;
    
    // Initialize RTP socket
    rtpSocket = [[ALiRTPSocket alloc] initWithPort:_rtpClientPort];
    _rtpClientPort = [rtpSocket.socket localPort];
}

- (void)setup:(NSString *)url
{
    _url = url;
    [self setup];
}

- (void)setup
{
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"SETUP %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %d\r\n", ++_cseq];
    [request appendFormat:@"Transport: RTP/AV;%@=%d-%d\r\n", (_unicast ? @"unicast;client_port" : @"multicast;port"), _rtpClientPort, _rtcpClientPort];
    [request appendString:@"\r\n"];
    
    // Send request
    NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    [rtspSocket writeData:data withTimeout:-1.0 tag:SETUP];
    
    // Start read data
    [rtspSocket readDataWithTimeout:-1 buffer:rtspInputBuffer bufferOffset:0 tag:SETUP];
}

- (void)play:(NSString *)url
{
    _url = url;
    [self play];
}

- (void)play
{
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"PLAY %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %d\r\n", ++_cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendString:@"\r\n"];
    
    // Send request
    NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    [rtspSocket writeData:data withTimeout:-1.0 tag:PLAY];
    
    // Start read data
    [rtspSocket readDataWithTimeout:-1 buffer:rtspInputBuffer bufferOffset:0 tag:PLAY];
}

- (void)options
{
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"OPTIONS %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %d\r\n", ++_cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendString:@"\r\n"];
    
    // Send request
    NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    [rtspSocket writeData:data withTimeout:-1.0 tag:OPTIONS];
    
    // Start read data
    [rtspSocket readDataWithTimeout:-1 buffer:rtspInputBuffer bufferOffset:0 tag:OPTIONS];
}

- (void)teardown
{
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"TEARDOWN %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %d\r\n", ++_cseq];
    [request appendFormat:@"Session: %@\r\n", _sessionID];
    [request appendFormat:@"Connection: close\r\n"];
    [request appendString:@"\r\n"];
    
    // Send request
    NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    [rtspSocket writeData:data withTimeout:-1.0 tag:TEARDOWN];
    
    // Start read data
    [rtspSocket readDataWithTimeout:-1 buffer:rtspInputBuffer bufferOffset:0 tag:TEARDOWN];
}

- (void)describe
{
    
}

- (NSDictionary *)parseRTSPAnswer:(NSString *)answer
{
    // Check if the received message is an RTSP answer and extract error code and error message form request line
    NSRegularExpression *regexHeader = [NSRegularExpression regularExpressionWithPattern:@"RTSP/1\\.0 (\\d+) (.*)"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSTextCheckingResult *matchHeader = [regexHeader firstMatchInString:answer options:0 range:NSMakeRange(0, [answer length])];
    if (matchHeader == nil) {
        NSLog(@"This is not an RTSP message");
        [_delegate error:@"This is not an RTSP message"];
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
    
    // Check validity of Cseq
    if ([[arguments objectForKey:@"CSeq"] intValue] != _cseq) {
        NSLog(@"Wrong CSeq number!");
        return nil;
    }
    
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
    NSDictionary *headers = [self parseRTSPAnswer:receivedString];
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
                NSLog(@"Malformed RTSP answer for SETUP message!");
                [_delegate error:@"Malformed RTSP answer for SETUP message!"];
                return;
            }
            
            // Extract stream ID
            if ((obj = [headers objectForKey:@"com.ses.streamID"]) != nil) {
                _streamID = [obj intValue];
            } else {
                NSLog(@"Malformed RTSP answer for SETUP message!");
                [_delegate error:@"Malformed RTSP answer for SETUP message!"];
                return;
            }
            
            // Start timer to maintain session alive
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSTimer scheduledTimerWithTimeInterval:_sessionTimeout
                                                 target:self
                                               selector:@selector(sessionTimeoutCallback)
                                               userInfo:nil
                                                repeats:YES];
            });
            
            // Set status
            _status = SET;
            
            // Notify delegate if status change
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate sessionSetup:self];
            });
            
            break;
        }
            
        case PLAY: {
//            NSLog(@"Received answer to PLAY message");
            
            // Set status
            _status = PLAYING;
            
            // Notify delegate of status change
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate sessionPlaying:self];
            });
            
            break;
        }
            
        case OPTIONS:
//            NSLog(@"Received answer to OPTIONS message");
            break;
            
        case TEARDOWN: {
//            NSLog(@"Received answer to TEARDOWN message");
            
            // Set status
            _status = IDLE;
            
            // Notify delegate of status change
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate sessionTeardowned:self];
            });
            
            break;
        }
            
        case DESCRIBE:
//            NSLog(@"Received answer to DESCRIBE message");
            break;
            
    }
}

- (void)sessionTimeoutCallback
{
    [self options];
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

- (void)packetsAvailable:(ALiRTPSocket *)socket packets:(NSArray *)packets ssrc:(const UInt32)ssrc
{
}

@end
