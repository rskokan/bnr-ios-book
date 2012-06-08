//
//  HeavyViewController.m
//  HeavyRotation
//
//  Created by Radek Skokan on 5/17/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "HeavyViewController.h"

@interface HeavyViewController ()

@end

@implementation HeavyViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return (orientation == UIInterfaceOrientationPortrait
            || UIInterfaceOrientationIsLandscape(orientation));
}

@end
