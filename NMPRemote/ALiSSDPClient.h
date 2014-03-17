//
//  ALiSSDPClient.h
//  NMPRemote
//
//  Created by Marc Gandillon on 13.03.14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiSSDPClient : NSObject <NSStreamDelegate>

- (id)init;
- (void)searchForDevices:(NSString *)urn;

@end
