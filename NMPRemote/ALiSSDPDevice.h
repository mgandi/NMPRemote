//
//  ALiSSDPDevice.h
//  NMPRemote
//
//  Created by Abilis Systems on 18/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiSSDPDevice : NSObject

@property (nonatomic, copy) NSString *requestLine;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *nts;
@property (nonatomic, copy) NSString *urn;
@property (nonatomic, copy) NSDictionary *arguments;

@end
