//
//  BNRContainer.h
//  RandomPossesions
//
//  Created by Radek Skokan on 5/14/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRItem.h"

@interface BNRContainer : BNRItem
{
    NSMutableArray *subitems;
}

- (id)initWithContainerName:(NSString *)name serialNumber:(NSString *) sNumber subitems:(NSMutableArray *) sItems;
- (id)initWithContainerName:(NSString *)name serialNumber:(NSString *) sNumber;

- (void)addItem:(BNRItem *)item;

@end
