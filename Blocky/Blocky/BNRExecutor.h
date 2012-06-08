//
//  BNRExecutor.h
//  Blocky
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRExecutor : NSObject
{

}

@property (nonatomic, copy) int (^equation)(int, int);

- (int)computeWithValue:(int)value1 andValue:(int)value2;

@end
