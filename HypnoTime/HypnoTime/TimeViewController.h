//
//  TimeViewController.h
//  HypnoTime
//
//  Created by Radek Skokan on 5/17/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeViewController : UIViewController
{
    __weak IBOutlet UILabel *timeLabel;
}

- (IBAction)showCurrentTime:(id)sender;

- (void)spinTimeLabel;
- (void)bounceTimeLabel;

@end
