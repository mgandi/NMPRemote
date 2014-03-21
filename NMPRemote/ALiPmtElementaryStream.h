//
//  ALiPmtElementaryStream.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiPmtElementaryStream : NSObject

@property (nonatomic, assign, readonly) UInt16 pid;
@property (nonatomic, assign, readonly) UInt16 type;

- (id)initWithPid:(const UInt16)pid andType:(const UInt16)type;

@end
