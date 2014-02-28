//
//  ALiM3uParser.h
//  NMPRemote
//
//  Created by Abilis Systems on 28/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALiM3uParser : NSObject

+ (NSMutableArray *)parse:(NSString *)path;

@end
