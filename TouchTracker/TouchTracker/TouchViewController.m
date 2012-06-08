//
//  TouchViewController.m
//  TouchTracker
//
//  Created by Radek Skokan on 5/24/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "TouchViewController.h"
#import "TouchDrawView.h"

@implementation TouchViewController

- (void)loadView
{
    [self setView:[[TouchDrawView alloc] initWithFrame:CGRectZero]];
}

@end
