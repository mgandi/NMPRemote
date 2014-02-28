//
//  ALiDongle.m
//  NMPRemote
//
//  Created by Abilis Systems on 24/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiDongle.h"
#import "ALiJSONCmd.h"
#import <dispatch/dispatch.h>

#define DONGLE_POR 13912

@implementation ALiDongle
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSData *syncWord;
    ALiJSONCmd *cmd;
    dispatch_queue_t network_queue;
}

- (id)init
{
    /* Initialize sync word */
    char bytes[] = "nmp";
    syncWord = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    /* Initialize JSON command object */
    cmd = [[ALiJSONCmd alloc] init];
    
    /* Create network dispatch queue */
    network_queue = dispatch_queue_create("tw.com.ali.network", NULL);
    
    return self;
}


- (void)queryInformation:(Boolean)encode message:(NSString *)message
{
    dispatch_async(network_queue, ^{
        /* Create input and output streams */
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.address, DONGLE_POR, &readStream, &writeStream);
        inputStream = (__bridge NSInputStream *)readStream;
        outputStream = (__bridge NSOutputStream *)writeStream;
        
        /* Open streams */
        [inputStream open];
        [outputStream open];
        
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
    
    
    
        /* Read answer */
        uint8_t inBuffer[4];
        uint32_t syncLength;
        int len = 0;
        
        /* Wait for bytes available */
        while (![inputStream hasBytesAvailable]);
        
        /* Check syncword */
        len = [inputStream read:inBuffer maxLength:sizeof(inBuffer)];
        if (len != 4) {
            NSLog(@"Syncword length should be 4, but got data length: %d!", len);
            return;
        }
        NSData *receivedSyncWord = [NSData dataWithBytes:inBuffer length:sizeof(inBuffer)];
        if (![receivedSyncWord isEqualToData:syncWord]) {
            NSLog(@"Syncword error!");
            return;
        }
        
        /* Wait for bytes available */
        while (![inputStream hasBytesAvailable]);
        
        /* Get length of message */
        len = [inputStream read:(uint8_t *)&syncLength maxLength:sizeof(syncLength)];
        if (len != 4) {
            NSLog(@"Synclen length should be 4, but got data length: %d!", len);
            return;
        }
        syncLength = CFSwapInt32BigToHost(syncLength);
        NSLog(@"Size of data: %d", syncLength);
        
        /* Wait for bytes available */
        while (![inputStream hasBytesAvailable]);
        
        /* Read data */
        NSMutableData *dataIn = [NSMutableData dataWithLength:syncLength];
        len = [inputStream read:(uint8_t *)[dataIn bytes] maxLength:[dataIn length]];
        if (len > 0) {
            
            NSString *input = [[NSString alloc] initWithBytes:[dataIn bytes] length:len - 1 encoding:NSASCIIStringEncoding];
            
            if (nil != input) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"server said: %@", input);
                    NSDictionary *dict = [cmd parse:input];
                    
                    if (dict != nil) {
                        NSNumber *ID = [dict valueForKey:@"id"];
                        
                        //Do Something
                        switch ([ID unsignedIntValue]) {
                            case NMP_CMD_ID_APKINFO:
                                [self.delegate appInformationReceived:self dict:dict];
                                break;
                                
                            case NMP_CMD_ID_DEVICEINFO:
                                [self.delegate deviceInformationReceived:self dict:dict];
                                break;
                                
                            case NMP_CMD_ID_WIFIISCONNECTED:
                                [self.delegate deviceWifiInformationReceived:self dict:dict];
                                break;
                                
                            case NMP_CMD_ID_GETCHANNEL:
                                [self.delegate deviceWifiChannelInformationReceived:self dict:dict];
                                break;
                                
                            default:
                                break;
                        }
                    }
                });
            }
        }
        
        /* Close streams */
        [inputStream close];
        [outputStream close];
    });
}

- (void)sendCommand:(Boolean)encode message:(NSString *)message
{
    dispatch_async(network_queue, ^{
        /* Create input and output streams */
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.address, DONGLE_POR, &readStream, &writeStream);
        inputStream = (__bridge NSInputStream *)readStream;
        outputStream = (__bridge NSOutputStream *)writeStream;
        
        /* Open streams */
        [inputStream open];
        [outputStream open];
        
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
        
        /* Close streams */
        [inputStream close];
        [outputStream close];
    });
}


- (void)getAppVersionInfo
{
    [self queryInformation:true message:[cmd generateAppInfoRequest]];
}

- (void)getDeviceInfo
{
    [self queryInformation:true message:[cmd generateDeviceInfoRequest]];
}

- (void)getDeviceWifiInfo
{
    [self queryInformation:true message:[cmd generateDeviceWifiInfoRequest]];
}

- (void)getDeviceWifiChannelInfo
{
    [self queryInformation:true message:[cmd generateDeviceWifiChannelInfoRequest]];
}


- (void)playback:(NSString *)url
{
    [self sendCommand:true message:[cmd generatePlaybackRequest:url]];
}

- (void)stopPlayback
{
    [self sendCommand:true message:[cmd generateStopPlaybackRequest]];
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
