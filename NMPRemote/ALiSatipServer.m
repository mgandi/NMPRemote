//
//  ALiSatipServer.m
//  NMPRemote
//
//  Created by Abilis Systems on 18/03/14.
//  Copyright (c) 2014 Abilis Systems. All rights reserved.
//

#import "ALiSatipServer.h"

@implementation ALiSatipServer
{
    NSMutableString *currentText;
    NSMutableArray *prefixes;
    
    NSString *friendlyName;
}

- (id)initWithSSDPDevice:(ALiSSDPDevice *)device
{
    currentText = [NSMutableString stringWithString:@""];
    prefixes = [NSMutableArray arrayWithCapacity:0];
    
    friendlyName = @"";
    
    _device = device;
    [self getDeviceInformation];
    return self;
}

- (void)getDeviceInformation
{
    // Extract location from device
    NSString *url =[_device.arguments objectForKey:@"LOCATION"];
    
    // Initialize parser and luanch parsing
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    [parser setDelegate:self];
    [parser parse];
}

- (NSString *)getFriendlyName
{
    return friendlyName;
}

#pragma mark - XML Parser delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"root"] || [elementName isEqualToString:@"specVersion"] || [elementName isEqualToString:@"device"]) {
        [prefixes addObject:elementName];
        return;
    }
    
    currentText = [NSMutableString stringWithString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"root"] || [elementName isEqualToString:@"specVersion"] || [elementName isEqualToString:@"device"]) {
        if (![[prefixes lastObject] isEqualToString:elementName])
            return;
        
        [prefixes removeLastObject];
        currentText = [NSMutableString stringWithString:@""];
        return;
    }
    
    
    // Create information path
    NSMutableString *path = [NSMutableString stringWithString:[prefixes componentsJoinedByString:@"/"]];
    [path appendString:@"/"];
    [path appendString:elementName];
    
//    NSLog(@"%@ = %@", path, currentText);
    
    // Test each information paths
    if ([path isEqualToString:@"root/device/friendlyName"]) {
        friendlyName = currentText;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentText appendString:string];
}

@end
