//
//  ALiProgram.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiProgram : NSObject

@property (nonatomic, assign, readonly) double frequency;
@property (nonatomic, assign, readonly) UInt8 bandwidth;
@property (nonatomic, assign, readonly) UInt16 tsID;
@property (nonatomic, assign, readonly) UInt16 number;
@property (nonatomic, assign, readonly) UInt16 pid;
@property (nonatomic, copy) NSString *serviceProviderName;
@property (nonatomic, copy) NSString *serviceName;
@property (nonatomic, assign) UInt16 pcrPid;
@property (nonatomic, copy) NSMutableDictionary *elementaryStreams;

- (id)initWithFrequency:(const double)frequency
              bandwidth:(const UInt8)bandwidth
                   tsId:(const UInt16)tsID
                 number:(const UInt16)number
                    pid:(const UInt16)pid;

- (NSString *)urlWithScheme:(NSString *)scheme
                       host:(NSString *)host;

@end
