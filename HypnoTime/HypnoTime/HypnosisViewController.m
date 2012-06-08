//
//  HypnosisViewController.m
//  HypnoTime
//
//  Created by Radek Skokan on 5/17/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "HypnosisViewController.h"
#import "HypnosisView.h"

@implementation HypnosisViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Hypnosis"];
        
        UIImage *img = [UIImage imageNamed:@"Hypno.png"];
        [tbi setImage:img];
    }
    
    return self;
}

- (void)loadView
{
    NSLog(@"HypnosisViewController loadView");
    CGRect frame = [[UIScreen mainScreen] bounds];
    HypnosisView *v = [[HypnosisView alloc] initWithFrame:frame];
    [self setView:v];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"HypnosisViewController viewDidLoad");
}

@end
