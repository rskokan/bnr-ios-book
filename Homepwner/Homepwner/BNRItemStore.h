//
//  BNRItemStore.h
//  Homepwner
//
//  Created by Radek Skokan on 5/18/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BNRItem;

@interface BNRItemStore : NSObject
{
    NSMutableArray *allItems;
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (BNRItemStore *)sharedStore;

- (NSArray *)allItems;
- (BNRItem *)createItem;
- (void)removeItem:(BNRItem *)item;
- (void)moveItemAtIndex:(int)from toIndex:(int)to;
- (NSArray *)allAssetTypes;

- (NSString *)itemArchivePath;
- (BOOL)saveChanges;
- (void)loadAllItems;

@end
