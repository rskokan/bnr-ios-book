//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Radek Skokan on 5/18/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRImageStore.h"

@implementation BNRItemStore

+ (BNRItemStore *)sharedStore
{
    static BNRItemStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}


+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Read in Homepwner.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSURL *storeURL = [NSURL fileURLWithPath:[self itemArchivePath]];
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&error]) {
            [NSException raise:@"DB open failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
        
        [self loadAllItems];
    }
    
    return self;
}


- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}


- (BOOL)saveChanges
{
    NSError *err;
    BOOL success = [context save:&err];
    if (!success) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    
    return success;
}


- (void)loadAllItems
{
    if (!allItems) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *ent = [[model entitiesByName] objectForKey:@"BNRItem"];
        [req setEntity:ent];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
        [req setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        NSError *err;
        NSArray *res = [context executeFetchRequest:req error:&err];
        if (!res) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [err localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:res];
    }
}


- (NSArray *)allItems
{
    return allItems;
}


- (BNRItem *)createItem
{
    double order;
    if ([allItems count] == 0) {
        order = 1.0;
    } else {
        order = [[allItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding after %d items, order = %.2f", [allItems count], order);
    
    BNRItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem"
                                                  inManagedObjectContext:context];
    [item setOrderingValue:order];
    
    [allItems addObject:item];
    return item;
}


- (void)removeItem:(BNRItem *)item
{
    NSString *imageKey = [item imageKey];
    [[BNRImageStore sharedStore] deleteImageForKey:imageKey];
    [context deleteObject:item];
    [allItems removeObjectIdenticalTo:item];
}


- (void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to) {
        return;
    }
    
    BNRItem *item = [allItems objectAtIndex:from];
    [allItems removeObjectAtIndex:from];
    [allItems insertObject:item atIndex:to];
    
    double lowerBound = 0.0;
    // Is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allItems objectAtIndex:to - 1] orderingValue];
    } else {
        lowerBound = [[allItems objectAtIndex:1] orderingValue] - 2.0;
    }
    
    double upperBound = 0.0;
    // Is there an object after in the array?
    if (to < [allItems count] - 1) {
        upperBound = [[allItems objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allItems objectAtIndex:to -1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"Moving item to order %f", newOrderValue);
    [item setOrderingValue:newOrderValue];
}


- (NSArray *)allAssetTypes
{
    if (!allAssetTypes) {
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        NSEntityDescription *ent = [[model entitiesByName] objectForKey:@"BNRAssetType"];
        [req setEntity:ent];
        
        NSError *err;
        NSArray *res = [context executeFetchRequest:req error:&err];
        if (!res) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [err localizedDescription]];
        }
        allAssetTypes = [res mutableCopy];
    }
    
    // The first time the program is being run create some default asset types
    if ([allAssetTypes count] == 0) {
        NSManagedObject *type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:context];
        [type setValue:@"Furniture" forKey:@"label"];
        [allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:context];
        [type setValue:@"Jewelery" forKey:@"label"];
        [allAssetTypes addObject:type];
        
        type = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType" inManagedObjectContext:context];
        [type setValue:@"Electronics" forKey:@"label"];
        [allAssetTypes addObject:type];
    }
    
    return allAssetTypes;
}

@end
