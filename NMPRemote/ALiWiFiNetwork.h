//
//  ALiWiFiNetwork.h
//  NMPRemote
//
//  Created by Abilis Systems on 04/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiWiFiNetwork : NSObject

@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *protection;
@property (nonatomic, assign) long strength;
@property (nonatomic, assign) int status;

@end
