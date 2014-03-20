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

@implementation ALiRTSPSession
{
    GCDAsyncSocket *input, *output;
//    NSInputStream *input;
//    NSOutputStream *output;
    unsigned int cseq;
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
}

- (id)init
{
    return [self initWithServer:nil url:@"" rtpClientPort:45454 rtcpClientPort:45455 unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url
{
    return [self initWithServer:server url:url rtpClientPort:45454 rtcpClientPort:45455 unicast:YES];
}

- (id)initWithServer:(ALiSatipServer *)server url:(NSString *)url rtpClientPort:(unsigned short)rtpClientPort rtcpClientPort:(unsigned short)rtcpClientPort unicast:(BOOL)unicast
{
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
    
    // Initialize network communication
    [self initNetworkCommunication];
    
    return self;
}

- (void)initNetworkCommunication
{
    NSError *error = nil;
    
    // Initialize dispatch queue
    socketQueue = dispatch_queue_create("tw.com.ali.rtsp", NULL);
    
    // Create our output GCDAsyncSocket instance.
	// Notice that we give it the normal delegate AND a delegate queue.
	// The socket will do all of its operations in a background queue,
	// and you can tell it which thread/queue to invoke your delegate on.
	output = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    if (![output connectToHost:_server.device.address onPort:554 error:&error]) {
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
    
    // Setup our input socket.
    // The socket will invoke our delegate methods using the usual delegate paradigm.
    // However, it will invoke the delegate methods on a specified GCD delegate dispatch queue.
    input = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
	if (![input acceptOnPort:0 error:&error]) {
		NSLog(@"Error in acceptOnPort:error: -> %@", error);
	}
    
    /*
    dispatch_async(socketQueue, ^{
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        // Initialize sockets
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)[NSString stringWithFormat:@"%@", _server.device.address], 554, &readStream, &writeStream);
        input = (__bridge NSInputStream *)readStream;
        output = (__bridge NSOutputStream *)writeStream;
        
        // Start current queues run loop
        [[NSRunLoop currentRunLoop] run];
        
        // Set delegate to self
        [input setDelegate:self];
        [output setDelegate:self];
        
        // schedule Socket to current run loop
        [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // Open sockets
        [input open];
        [output open];
    });
    */
}

- (void)setup
{
    /*
    dispatch_async(socketQueue, ^{
        // Build RTSP request
        NSMutableString *request = [NSMutableString stringWithFormat:@"SETUP %@ RTSP/1.0\r\n", _url];
        [request appendFormat:@"CSeq: %d\r\n", ++cseq];
        [request appendFormat:@"Transport: RTP/AV;%@=%d-%d\r\n", (_unicast ? @"unicast;client_port" : @"multicast;port"), _rtpClientPort, _rtcpClientPort];
        [request appendString:@"\r\n"];
        
        // Send request
        NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
        [output write:[data bytes] maxLength:[data length]];
    });
    */
    
    // Build RTSP request
    NSMutableString *request = [NSMutableString stringWithFormat:@"SETUP %@ RTSP/1.0\r\n", _url];
    [request appendFormat:@"CSeq: %d\r\n", ++cseq];
    [request appendFormat:@"Transport: RTP/AV;%@=%d-%d\r\n", (_unicast ? @"unicast;client_port" : @"multicast;port"), _rtpClientPort, _rtcpClientPort];
    [request appendString:@"\r\n"];
    
    // Send request
    NSData *data = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    [output writeData:data withTimeout:-1.0 tag:0];
}

#pragma mark - GCDAsynchSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	// This method is executed on the socketQueue (not the main thread)
	@synchronized(connectedSockets)
	{
		[connectedSockets addObject:newSocket];
	}
    
    /*
	NSString *host = [newSocket connectedHost];
	UInt16 port = [newSocket connectedPort];
    
	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
	[newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
    */
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    /*
	// This method is executed on the socketQueue (not the main thread)
	if (tag == ECHO_MSG)
	{
		[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
	}
    */
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    /*
	// This method is executed on the socketQueue (not the main thread)
	dispatch_async(dispatch_get_main_queue(), ^{
		@autoreleasepool {
            
			NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
			NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
			if (msg)
			{
				[self logMessage:msg];
			}
			else
			{
				[self logError:@"Error converting received data into UTF-8 String"];
			}
            
		}
	});
    
	// Echo message back to client
	[sock writeData:data withTimeout:-1 tag:ECHO_MSG];
    */
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    /*
	if (elapsed <= READ_TIMEOUT)
	{
		NSString *warningMsg = @"Are you still there?\r\n";
		NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
		[sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
        
		return READ_TIMEOUT_EXTENSION;
	}
    */
    
	return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != input)
	{
        /*
		dispatch_async(dispatch_get_main_queue(), ^{
			@autoreleasepool {
                
				[self logInfo:FORMAT(@"Client Disconnected")];
                
			}
		});
        */
        
		@synchronized(connectedSockets)
		{
			[connectedSockets removeObject:sock];
		}
	}
}

@end
