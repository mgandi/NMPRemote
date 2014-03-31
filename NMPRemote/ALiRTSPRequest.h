//
//  ALiRTSPRequest.h
//  NMPRemote
//
//  Created by Abilis Systems on 31/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SETUP = 1,
    PLAY = 2,
    OPTIONS = 3,
    TEARDOWN = 4,
    DESCRIBE = 5
} MessageTypes;

@interface ALiRTSPRequest : NSObject

@property (nonatomic, assign) MessageTypes type;
@property (nonatomic, copy) NSString *request;
@property (nonatomic, copy) NSString *answer;

- (id)initWithType:(MessageTypes)type andRequest:(NSString *)request;

@end
