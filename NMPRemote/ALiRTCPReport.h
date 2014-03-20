//
//  ALiRTCPReport.h
//  NMPRemote
//
//  Created by Abilis Systems on 20/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiRTCPReport : NSObject

@property (nonatomic, assign) UInt32 packetCount;
@property (nonatomic, assign) UInt32 ssrc;
@property (nonatomic, copy) NSDictionary *arguments;

@end
