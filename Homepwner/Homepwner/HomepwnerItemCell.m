//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Radek Skokan on 5/22/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell
@synthesize thumbnailView;
@synthesize nameLabel;
@synthesize serialNumberLabel;
@synthesize valueLabel;
@synthesize controller;
@synthesize tableView;

- (IBAction)showImage:(id)sender
{
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    
    NSString *selector = NSStringFromSelector(_cmd);
    // Now the selector is showImage:
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    SEL newSelector = NSSelectorFromString(selector);
    
    if (indexPath) {
        if ([[self controller] respondsToSelector:newSelector]) {
            [[self controller] performSelector:newSelector
                                    withObject:sender
                                    withObject:indexPath];
        } else {
            NSLog(@"Problem, %@ doesn't respond to %@", [self controller], NSStringFromSelector(newSelector));
        }
    }
    
    
}

@end
