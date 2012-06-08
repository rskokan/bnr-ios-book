//
//  BNRConnection.h
//  Nerdfeed
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//
//
// Actor design pattern

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface BNRConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSURLConnection *internelConnection;
    NSMutableData *container;
}

@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) void (^completionBlock)(id obj, NSError *err);

@property (nonatomic, strong) id <NSXMLParserDelegate> xmlRootObject;
@property (nonatomic, strong) id <JSONSerializable> jsonRootObject;

- (id)initWithrequest:(NSURLRequest *)req;
- (void)start;

@end
