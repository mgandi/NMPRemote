//
//  ALiPatProgram.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiPatProgram : NSObject

@property (nonatomic, assign, readonly) UInt16 pid;
@property (nonatomic, assign, readonly) UInt16 number;

- (id)initWithPid:(const UInt16)pid andNumber:(const UInt16)number;

@end
