//
//  ALiPidHandler.h
//  NMPRemote
//
//  Created by Abilis Systems on 21/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALiSection.h"

#ifndef checkChanged
#define checkChangedX(condition, changed) if (condition) { changed |= true; }
#define checkChangedXM(condition, changed, message) if (condition) { changed |= true; NSLog(@"%@ - changed: %@", NSStringFromClass([self class]), message); }
#define checkChanged(a, b, c) if (a != b) { a = b; c = true; }
#endif // checkChanged

@class ALiPidHandler;

@protocol ALiPidHandlerDelegate <NSObject>
- (void)parseTable:(ALiSection *)section;
@end

@interface ALiPidHandler : NSObject

@property (nonatomic, weak) id <ALiPidHandlerDelegate> pidHandlerDelegate;
@property (nonatomic, assign) UInt16 sectionMaxSize;
@property (nonatomic, assign) BOOL hasCRC;

- (void)push:(NSData *)packet;
- (void)attach;
- (void)dettach;
- (BOOL)isAttached;

@end
