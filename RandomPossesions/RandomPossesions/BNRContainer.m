//
//  BNRContainer.m
//  RandomPossesions
//
//  Created by Radek Skokan on 5/14/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRContainer.h"

@implementation BNRContainer

- (id)initWithContainerName:(NSString *)name serialNumber:(NSString *) sNumber subitems:(NSMutableArray *) sItems
{
    NSString *containerName = [NSString stringWithFormat:@"CONT %@", name];
    self = [super initWithItemName:containerName valueInDollars:0 serialNumber:sNumber];
    if (self) {
        subitems = sItems;
    }
    
    return self;
}

- (id)initWithContainerName:(NSString *)name serialNumber:(NSString *) sNumber
{
    NSMutableArray *emptySubitems = [[NSMutableArray alloc] init];
    return [self initWithContainerName:name serialNumber:sNumber subitems:emptySubitems];
}

- (void)addItem:(BNRItem *)item
{
    [subitems addObject:item];
}

- (void)setValueInDollars:(int)i
{
    NSLog(@"Setting value on a BNRContainer object is not supported!");
}

- (int)valueInDollars
{
    int valueOfAllSubitems = 0;
    
    for (BNRItem *subitem in subitems) {
        valueOfAllSubitems += [subitem valueInDollars];
    }
    
    return valueOfAllSubitems;
}

- (NSString *)description
{
    // the valueInDollars is now probably private and not visible in this subclass thanks to @property
//    valueInDollars = [self valueInDollars];
    NSMutableString *desc = [[NSMutableString alloc] initWithString:[super description]];
    [desc appendString:@"; subitems={"];
    for (BNRItem *item in subitems) {
        [desc appendString:[item description]];
        [desc appendString:@", "];
    }
    [desc appendString:@"}"];
    
    return desc;
}

@end
