//
//  BNRFeedStore.h
//  Nerdfeed
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSItem;
@class RSSChannel;

extern NSString * const BNRFeedStoreUpdateNotification;

@interface BNRFeedStore : NSObject
{
    NSManagedObjectContext *ctx;
    NSManagedObjectModel *model;
}

+ (BNRFeedStore *)sharedStore;

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *ch, NSError *err))block;
- (void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *ch, NSError *err))block;

- (void)markItemAsRead:(RSSItem *)item;
- (BOOL)hasItemBeenRead:(RSSItem *)item;

@property (nonatomic, strong) NSDate *topSongsCacheDate;

@end
