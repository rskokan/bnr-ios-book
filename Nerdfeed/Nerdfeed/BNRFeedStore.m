//
//  BNRFeedStore.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRFeedStore.h"
#import "BNRConnection.h"
#import "RSSChannel.h"
#import "RSSItem.h"

NSString * const BNRFeedStoreUpdateNotification = @"BNRFeedStoreUpdateNotification";

@implementation BNRFeedStore

+ (BNRFeedStore *)sharedStore
{
    static BNRFeedStore *feedStore = nil;
    
    if (!feedStore) {
        feedStore = [[BNRFeedStore alloc] init];
    }
    
    return feedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        // Register for iCloud notifications
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(contentChange)
         name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
         object:nil];
        
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // iCloud
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *ubContainer = [fm URLForUbiquityContainerIdentifier:nil];
        // Tell Core Data where the transaction log should be stored
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:@"nerdfeed" forKey:NSPersistentStoreUbiquitousContentNameKey];
        [options setObject:ubContainer forKey:NSPersistentStoreUbiquitousContentURLKey];
        
        NSError *err = nil;
        
        // The feed DB file will be stored in the ub container that is specific per app&user. So that other iCloud users using
        // this device will se their contents. The .nosync extension says the file shouldn't be synced to iCloud
        NSURL *noSyncDir = [ubContainer URLByAppendingPathComponent:@"feed.nosync"];
        [fm createDirectoryAtURL:noSyncDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSURL *dbURL = [noSyncDir URLByAppendingPathComponent:@"feed.db"];
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil URL:dbURL options:options error:&err]) {
            [NSException raise:@"DB open failed" format:@"Reason: %@", err.localizedDescription];
        }
        
        ctx = [[NSManagedObjectContext alloc] init];
        [ctx setPersistentStoreCoordinator:psc];
        [ctx setUndoManager:nil];
        NSLog(@"Feed DB opened (%@)", [dbURL description]);
    }
    
    return self;
}

- (void)contentChange:(NSNotification *)notif
{
    // Merge changes (from the DB transaction log in iCloud) into the Core Data changes
    [ctx mergeChangesFromContextDidSaveNotification:notif];
    
    // Now notify Controllers about the change so that they can reload their views.
    // As this op is running in a background thread (it's called when an notification appears),
    // we will send the notification explicitly from the main thhread so that it will reach the controllers faster
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSNotification *updateNotif = [NSNotification notificationWithName:BNRFeedStoreUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:updateNotif];
    }];
}

- (void)markItemAsRead:(RSSItem *)item
{
    // Check if the item is already marked to avoid duplicates in DB
    if ([self hasItemBeenRead:item])
        return;
    
    // We just store the links (URLs) of already read items in the DB entities
    NSManagedObject *obj = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:ctx];
    [obj setValue:[item link] forKey:@"urlString"];
    [ctx save:nil];
}

- (BOOL)hasItemBeenRead:(RSSItem *)item
{
    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"Link"];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"urlString like %@", [item link]];
    [req setPredicate:pred];
    NSArray *entries = [ctx executeFetchRequest:req error:nil];
    if ([entries count] > 0)
        return YES;
    
    return NO;
}

- (RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *, NSError *))block
{
    NSURL *url = [NSURL URLWithString:@"http://forums.bignerdranch.com/smartfeed.php?limit=1_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    RSSChannel *channel = [[RSSChannel alloc] init];
    BNRConnection *conn = [[BNRConnection alloc] initWithrequest:req];

    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"nerd.archive"];
    RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if (!cachedChannel)
        cachedChannel = [[RSSChannel alloc] init];
    RSSChannel *channelCopy = [channel copy];
    
    [conn setCompletionBlock:^(RSSChannel *ch, NSError *err) {
        if (!err) {
            [channelCopy addItemsFromChannel:ch];
            [NSKeyedArchiver archiveRootObject:channelCopy toFile:cachePath];
        }
        
        block(channelCopy, err);
    }];
    
    [conn setXmlRootObject:channel];
    [conn start];
    
    return cachedChannel;
}

- (void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *, NSError *))block
{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES) objectAtIndex:0];
    cachePath = [cachePath stringByAppendingPathComponent:@"appleFeed.archive"];
    
    NSDate *tscDate = [self topSongsCacheDate];
    if (tscDate) {
        NSTimeInterval cacheAge = [tscDate timeIntervalSinceNow];
        if (cacheAge > -300) {
            NSLog(@"Using cache");
            RSSChannel *cachedChannel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
            if (cachedChannel) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    block(cachedChannel, nil);
                }];
                return;
            }
        }
    }
    
    NSLog(@"Cache is too old, fetching from the Net");
    NSString *requestString = [NSString stringWithFormat:@"http://itunes.apple.com/us/rss/topsongs/limit=%d/json", count];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    RSSChannel *channel = [[RSSChannel alloc] init];
    BNRConnection *conn = [[BNRConnection alloc] initWithrequest:req];
    [conn setCompletionBlock:^(RSSChannel *ch, NSError *err) {
        // Add store's completion block
        if (!err) {
            [self setTopSongsCacheDate:[NSDate date]];
            [NSKeyedArchiver archiveRootObject:ch toFile:cachePath];
        }
        
        // The original controller's completion block
        block(ch, err);
    }];
    [conn setJsonRootObject:channel];
    [conn start];
}

- (void)setTopSongsCacheDate:(NSDate *)topSongsCacheDate
{
    [[NSUserDefaults standardUserDefaults] setObject:topSongsCacheDate forKey:@"topSongsCacheDate"];
}

- (NSDate *)topSongsCacheDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"topSongsCacheDate"];
}

@end
