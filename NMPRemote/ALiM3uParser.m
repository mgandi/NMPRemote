//
//  ALiM3uParser.m
//  NMPRemote
//
//  Created by Abilis Systems on 28/02/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiM3uParser.h"
#import "ALiM3uItem.h"

@implementation ALiM3uParser

+ (NSMutableArray *)parse:(NSString *)path
{
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
    NSMutableArray *m3uItems = [[NSMutableArray alloc] initWithCapacity:0];

    if (content == nil) {
        NSLog(@"Error opening file: %@", error);
        return m3uItems;
    }
    
    content = [content stringByReplacingOccurrencesOfString:@"#EXTM3U" withString:@""];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\n]+" options:NSRegularExpressionCaseInsensitive error:&error];
    content = [regex stringByReplacingMatchesInString:content options:0 range:NSMakeRange(0, [content length]) withTemplate:@""];
    NSArray *tokens = [content componentsSeparatedByString:@"#EXTINF:"];
    
    for (id token in tokens) {
        NSRegularExpression *match = [NSRegularExpression regularExpressionWithPattern:@"\\d,\\d\\.\\s(.*)(http.*)" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [match matchesInString:token options:0 range:NSMakeRange(0, [token length])];
        if ([matches count]) {
            for (id m in matches) {
                ALiM3uItem *item = [[ALiM3uItem alloc] init];
                item.name = [token substringWithRange:[m rangeAtIndex:1]];
                item.url = [token substringWithRange:[m rangeAtIndex:2]];
                [m3uItems addObject:item];
            }
        }
    }
    
    return m3uItems;
}

@end
