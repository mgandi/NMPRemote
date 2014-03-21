//
//  ALiSdtService.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Undefined         = 0x00,
    NotRunning        = 0x01,
    StartInFewSeconds = 0x02,
    Pausing           = 0x03,
    Running           = 0x04,
    ServiceOffAir     = 0x05
} RuningStatus;

@interface ALiSdtService : NSObject

@property (nonatomic, assign, readonly) UInt16 serviceId;
@property (nonatomic, assign, readonly) RuningStatus runingStatus;
@property (nonatomic, copy, readonly) NSString *serviceProviderName;
@property (nonatomic, copy, readonly) NSString *serviceName;
@property (nonatomic, assign, readonly) BOOL scrambled;

- (id)initWithServiceID:(const UInt16)serviceId
           runingStatus:(const RuningStatus)runingStatus
    serviceProviderName:(NSString *)serviceProviderName
            serviceName:(NSString *)serviceName
              scrambled:(BOOL)scrambled;

@end
