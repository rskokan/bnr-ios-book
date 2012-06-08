//
//  BNRExecutor.m
//  Blocky
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRExecutor.h"

@implementation BNRExecutor

@synthesize equation;

- (int)computeWithValue:(int)value1 andValue:(int)value2
{
    if (!equation)
        return 0;
    
    return equation(value1, value2);
}

- (void)dealloc
{
    NSLog(@"Excecutor is being destroyed");
}

@end
