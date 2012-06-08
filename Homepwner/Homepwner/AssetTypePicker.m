//
//  AssetTypePicker.m
//  Homepwner
//
//  Created by Radek Skokan on 5/23/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "AssetTypePicker.h"
#import "BNRItem.h"
#import "BNRItemStore.h"

@implementation AssetTypePicker

@synthesize item;

- (id)init
{
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id) initWithStyle:(UITableViewStyle)style
{
    return [self init];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allAssetTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
    NSManagedObject *assetType = [allAssets objectAtIndex:[indexPath row]];
    NSString *label = [assetType valueForKey:@"label"];
    [[cell textLabel] setText:label];
    
    // Checkmark the one that is currently selected
    if (assetType == [item assetType]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
    NSManagedObject *asset = [allAssets objectAtIndex:[indexPath row]];
    [item setAssetType:asset];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
