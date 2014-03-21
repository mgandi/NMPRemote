//
//  ALiSdtService.m
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSdtService.h"

@implementation ALiSdtService

- (id)initWithServiceID:(const UInt16)serviceId
           runingStatus:(const RuningStatus)runingStatus
    serviceProviderName:(NSString *)serviceProviderName
            serviceName:(NSString *)serviceName
              scrambled:(BOOL)scrambled
{
    _serviceId = serviceId;
    _runingStatus = runingStatus;
    _serviceProviderName = serviceProviderName;
    _serviceName = serviceName;
    _scrambled = scrambled;
    return self;
}

@end
