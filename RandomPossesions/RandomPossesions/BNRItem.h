//
//  BNRItem.h
//  RandomPossesions
//
//  Created by Radek Skokan on 5/14/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRItem : NSObject

+ (id)randomItem;

- (id)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *) sNumber;

- (id)initWithItemName:(NSString *)name serialNumber:(NSString *)sNumber;

@property (nonatomic, weak) BNRItem *container;
@property (nonatomic, strong) BNRItem *containedItem;
@property (nonatomic, copy) NSString *itemName;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic) int valueInDollars;
@property (nonatomic, readonly, strong) NSDate *dateCreated;

@end
