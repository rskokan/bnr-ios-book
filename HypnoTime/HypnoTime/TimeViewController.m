//
//  TimeViewController.m
//  HypnoTime
//
//  Created by Radek Skokan on 5/17/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "TimeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation TimeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Time"];
        
        UIImage *img = [UIImage imageNamed:@"Time.png"];
        [tbi setImage:img];
    }
    
    return self;
}

- (IBAction)showCurrentTime:(id)sender
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [timeLabel setText:[formatter stringFromDate:now]];
    
    NSLog(@"Calling spinTimeLabel");
    [self spinTimeLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"TimeViewController viewDidLoad");
    [[self view] setBackgroundColor:[UIColor greenColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showCurrentTime:nil];
}

- (void)spinTimeLabel
{
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setDelegate:self];
    [spin setToValue:[NSNumber numberWithFloat:2 * M_PI]];
    [spin setDuration:1.0];
    
    CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [spin setTimingFunction:tf];
    
    [[timeLabel layer] addAnimation:spin forKey:@"spinAnimation"];
}

- (void)bounceTimeLabel
{
    CAKeyframeAnimation *bounce = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D forward = CATransform3DMakeScale(1.5, 1.5, 1.0);
    CATransform3D back = CATransform3DMakeScale(0.7, 0.7, 1.0);
    CATransform3D forward2 = CATransform3DMakeScale(1.2, 1.2, 1.0);
    CATransform3D back2 = CATransform3DMakeScale(0.9, 0.9, 1.0);
    
    [bounce setValues:[NSArray arrayWithObjects:
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       [NSValue valueWithCATransform3D:forward],
                       [NSValue valueWithCATransform3D:back],
                       [NSValue valueWithCATransform3D:forward2],
                       [NSValue valueWithCATransform3D:back2],
                       [NSValue valueWithCATransform3D:CATransform3DIdentity],
                       nil]];
    [bounce setDuration:0.6];
    [[timeLabel layer] addAnimation:bounce forKey:@"bounceAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"Animation %@ stopped; finished: %d", anim, flag);
    [self bounceTimeLabel];
}

@end
