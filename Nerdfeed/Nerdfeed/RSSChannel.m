//
//  RSSChannel.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "RSSChannel.h"
#import "RSSItem.h"
#import "LogDef.h"

@implementation RSSChannel

@synthesize items, title, infoString, parentParserDelegate;

- (id)init
{
    self = [super init];
    if (self) {
        items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:items forKey:@"items"];
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:infoString forKey:@"infoString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        items = [aDecoder decodeObjectForKey:@"items"];
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setInfoString:[aDecoder decodeObjectForKey:@"infoString"]];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    RSSChannel *copy = [[[self class] alloc] init];
    [copy setTitle:[self title]];
    [ copy setInfoString:[self infoString]];
    copy->items = [self items];
    
    return copy;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    WSLog(@"\t%@ found a %@ element", self, elementName);
    
    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    } else if ([elementName isEqual:@"description"]) {
        currentString = [[NSMutableString alloc] init];
        [self setInfoString:currentString];
    } else if ([elementName isEqual:@"item"] || [elementName isEqualToString:@"entry"]) {
        RSSItem *item = [[RSSItem alloc] init];
        [item setParentParserDelegate:self];
        [parser setDelegate:item];
        [items addObject:item];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    currentString = nil;
    if ([elementName isEqual:@"channel"]) {
        [parser setDelegate:parentParserDelegate];
        [self trimItemTitles];
    }
}

- (void)trimItemTitles
{
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@".* :: (.*) :: .*"
                                                                    options:0
                                                                      error:nil];
    for (RSSItem *i in items) {
        NSString *itemTitle = [i title];
        NSArray *matches = [reg matchesInString:itemTitle
                                        options:0
                                          range:NSMakeRange(0, [itemTitle length])];
        if ([matches count] > 0) {
            NSTextCheckingResult *res = [matches objectAtIndex:0];
            NSRange range = [res range];
            NSLog(@"Match at {%d, %d} for %@", range.location, range.length, itemTitle);
            
            if ([res numberOfRanges] == 2) {
                range = [res rangeAtIndex:1];
                [i setTitle:[itemTitle substringWithRange:range]];
            }
        }
    }
}

- (void)readFromJSONDictionary:(NSDictionary *)dict
{
    NSDictionary *feed = [dict objectForKey:@"feed"];
    [self setTitle:[feed objectForKey:@"title"]];
    
    NSArray *entries = [feed objectForKey:@"entry"];
    for (NSDictionary *entry in entries) {
        RSSItem *i = [[RSSItem alloc] init];
        [i readFromJSONDictionary:entry];
        [items addObject:i];
    }
}

- (void)addItemsFromChannel:(RSSChannel *)aChannel
{
    for (RSSItem *i in [aChannel items]) {
        if (![[self items] containsObject:i])
            [[self items] addObject:i];
    }
    
    [[self items] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj2 publicationDate] compare:[obj1 publicationDate]];
    }];
}

@end
