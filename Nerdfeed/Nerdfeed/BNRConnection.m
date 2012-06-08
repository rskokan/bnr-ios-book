//
//  BNRConnection.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.

#import "BNRConnection.h"

// Holds references to the BNRConnection instances in order they not being garbage collected
static NSMutableArray *sharedConnectionList = nil;

@implementation BNRConnection

@synthesize request, completionBlock, xmlRootObject, jsonRootObject;

- (id)initWithrequest:(NSURLRequest *)req
{
    self = [super init];
    if (self) {
        [self setRequest:req];
    }
    
    return self;
}

- (void)start
{
    container = [[NSMutableData alloc] init];
    internelConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if (!sharedConnectionList) {
        sharedConnectionList = [[NSMutableArray alloc] init];
    }
    
    [sharedConnectionList addObject:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [container appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    id rootObject = nil;
    
    if ([self xmlRootObject]) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:container];
        [parser setDelegate:[self xmlRootObject]];
        [parser parse];
        rootObject = xmlRootObject;
    } else if([self jsonRootObject]) {
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:container options:0 error:nil];
        [[self jsonRootObject] readFromJSONDictionary:d];
        rootObject = [self jsonRootObject];
    }
    
    
    if ([self completionBlock]) {
        [self completionBlock](rootObject, nil);
    }
    
    [sharedConnectionList removeObject:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([self completionBlock]) {
        [self completionBlock](nil, error);
    }
    
    [sharedConnectionList removeObject:self];
}

@end
