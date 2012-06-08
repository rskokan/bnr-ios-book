//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Radek Skokan on 5/20/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRImageStore.h"

@implementation BNRImageStore

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}


+ (BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore  = nil;
    
    if (sharedStore == nil) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}


- (id)init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
                        selector:@selector(clearCache:)
                        name:UIApplicationDidReceiveMemoryWarningNotification
                        object:nil];
    }
    
    return self;
}


- (void)clearCache:(id)sender
{
    NSLog(@"Low memory, flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
}


- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    [dictionary setObject:image forKey:key];
    NSString *imagePath = [self imagePathForKey:key];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    NSLog(@"Starting writing image file...");
    [data writeToFile:imagePath atomically:YES];
    NSLog(@"IMage written to %@", imagePath);
}


- (UIImage *)imageForKey:(NSString *)key
{
    UIImage *res = [dictionary objectForKey:key];
    
    if (!res) {
        res = [UIImage imageWithContentsOfFile:[self imagePathForKey:key]];
        if (res) {
            [dictionary setObject:res forKey:key];
        } else {
            NSLog(@"No image file has been found for key %@", key);
        }
    }
    
    return res;
}


- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    
    [dictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:NULL];
}


- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:key];
}

@end
