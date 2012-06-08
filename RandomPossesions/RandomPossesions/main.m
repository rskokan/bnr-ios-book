//
//  main.m
//  RandomPossesions
//
//  Created by Radek Skokan on 5/14/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRItem.h"
#import "BNRContainer.h"

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        BNRItem *backpack = [[BNRItem alloc] init];
        [backpack setItemName:@"Backpack"];
        [items addObject:backpack];
        
        BNRItem *calculator = [[BNRItem alloc] init];
        [calculator setItemName:@"Calculator"];
        
        [items addObject:calculator];
        NSLog(@"Calc: %@", calculator);

        [backpack setContainedItem:calculator];
        NSLog(@"items=%@", items);
        
        NSLog(@"Releasing items");
        
        items = nil;
        
    }
    return 0;
}

