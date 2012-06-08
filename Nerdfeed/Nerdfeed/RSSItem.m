//
//  RSSItem.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "RSSItem.h"
#import "LogDef.h"

@implementation RSSItem

@synthesize title, link, parentParserDelegate, publicationDate;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:link forKey:@"link"];
    [aCoder encodeObject:publicationDate forKey:@"publicationDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
        [self setPublicationDate:[aDecoder decodeObjectForKey:@"publicationDate"]];
    }
    
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    WSLog(@"\t\t%@ found a %@ element", self, elementName);
    
    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    } else if ([elementName isEqual:@"link"]) {
        currentString = [[NSMutableString alloc] init];
        [self setLink:currentString];
    } else if ([elementName isEqual:@"pubDate"]) {
        currentString = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqual:@"pubDate"]) {
        static NSDateFormatter *dateFormatter = nil;
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, dd MM yyyy HH:mm:ss z"];
        }
        [self setPublicationDate:[dateFormatter dateFromString:currentString]];
    }
    
    currentString = nil;
    if ([elementName isEqual:@"item"] || [elementName isEqualToString:@"entry"]) {
        [parser setDelegate:parentParserDelegate];
    }
}

- (void)readFromJSONDictionary:(NSDictionary *)dict
{
    [self setTitle:[[dict objectForKey:@"title"] objectForKey:@"label"]];
    NSArray *links = [dict objectForKey:@"link"];
    if ([links count] > 0) {
        NSDictionary *sampleLink = [[links objectAtIndex:1] objectForKey:@"attributes"];
        [self setLink:[sampleLink objectForKey:@"href"]];
    }
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[RSSItem class]])
        return NO;
    
    return [[self link] isEqual:[object link]];
}

@end
