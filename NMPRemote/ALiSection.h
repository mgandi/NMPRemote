//
//  ALiSection.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiSection : NSObject

@property (nonatomic, copy) NSMutableData *data;
@property (nonatomic, assign) UInt16 need;
@property (nonatomic, assign) BOOL headerComplete;
@property (nonatomic, assign) UInt16 index;
@property (nonatomic, assign) BOOL validCRC;
@property (nonatomic, assign) const UInt8 *payload;
@property (nonatomic, assign) UInt16 payloadSize;

@property (nonatomic, assign) UInt8 tableID;
@property (nonatomic, assign) UInt8 sectionSyntaxIndicator;
@property (nonatomic, assign) UInt16 sectionLength;
@property (nonatomic, assign) UInt16 serviceID;
@property (nonatomic, assign) UInt8 versionNumber;
@property (nonatomic, assign) UInt8 currentNextIndicator;
@property (nonatomic, assign) UInt8 sectionNumber;
@property (nonatomic, assign) UInt8 lastSectionNumber;

@end
