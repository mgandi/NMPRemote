//
//  ALiDongle.m
//  NMPRemote
//
//  Created by Abilis Systems on 24/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDongle.h"
#import "ALiJSONCmd.h"

@implementation ALiDongle
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSData *syncWord;
    ALiJSONCmd *cmd;
}

- (id)init
{
    /* Initialize sync word */
    char bytes[] = "nmp";
    syncWord = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    /* Initialize JSON command object */
    cmd = [[ALiJSONCmd alloc] init];
    cmd.delegate = self;
    
    return self;
}

- (void)start
{
    /* Create input and output streams */
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.address, 13912, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    /* Assign self as delegate for input and output streams */
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    /* Schedule the stream to receive events in a run loop */
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    /* Open streams */
    [inputStream open];
    [outputStream open];
}

- (void)sendMessage:(Boolean)encode message:(NSString *)message
{
    NSLog(@"send json cmd: %@", message);
    
    /* Prepare message */
    NSString *msg = message;
    if (encode) {
        msg = [[ALiDongle class] base64String:message];
    }
    NSLog(@"Send message: %@", msg);
	NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    
    /* Send sync word */
	[outputStream write:[syncWord bytes] maxLength:[syncWord length]];
    
    /* Send length of message */
    int messageLength = CFSwapInt32HostToBig([data length]);
    NSData *syncLen = [NSData dataWithBytes:&messageLength length:sizeof(messageLength)];
	[outputStream write:[syncLen bytes] maxLength:[syncLen length]];
    
    /* Send message */
	[outputStream write:[data bytes] maxLength:[data length]];
    const uint8_t buffer = 0;
	[outputStream write:&buffer maxLength:sizeof(char)];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    //NSLog(@"stream event %i from %@", streamEvent, (theStream == inputStream) ? @"Input stream" : @"Output stream");
    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			//NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[4];
                uint32_t syncLen;
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    
                    /* Check syncword */
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len != 4) {
                        NSLog(@"Syncword length should be 4, but got data length: %d!", len);
                        return;
                    }
                    NSData *receivedSyncWord = [NSData dataWithBytes:buffer length:sizeof(buffer)];
                    if (![receivedSyncWord isEqualToData:syncWord]) {
                        NSLog(@"Syncword error!");
                        return;
                    }
                    
                    /* Get length of message */
                    len = [inputStream read:(uint8_t *)&syncLen maxLength:sizeof(syncLen)];
                    if (len != 4) {
                        NSLog(@"Synclen length should be 4, but got data length: %d!", len);
                        return;
                    }
                    syncLen = CFSwapInt32BigToHost(syncLen);
                    NSLog(@"Size of data: %d", syncLen);
                    
                    /* Read data */
                    NSMutableData *data = [NSMutableData dataWithLength:syncLen];
                    len = [inputStream read:(uint8_t *)[data bytes] maxLength:[data length]];
                    if (len > 0) {
                        
                        NSString *input = [[NSString alloc] initWithBytes:[data bytes] length:len - 1 encoding:NSASCIIStringEncoding];
                        
                        if (nil != input) {
                            //NSLog(@"server said: %@", input);
                            [cmd parse:input];
                        }
                    }
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
			//NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:
			//NSLog(@"Unknown event");
            break;
	}
}


- (void)checkAppMatchDongleVersion
{
    [self sendMessage:false message:[cmd generateAppInfoRequest]];
}

- (void)getDeviceInfo
{
    [self sendMessage:true message:[cmd generateDeviceInfoRequest]];
}

- (void)appInfoReceived:(NSDictionary *)dict
{
    [self.delegate appInformationReceived:self dict:dict];
}

- (void)deviceInfoReceived:(NSDictionary *)dict
{
    [self.delegate deviceInformationReceived:self dict:dict];
}


+ (NSString *)base64String:(NSString *)str
{
    NSData *theData = [str dataUsingEncoding: NSASCIIStringEncoding];
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
