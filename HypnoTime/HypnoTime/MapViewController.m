//
//  MapViewController.m
//  HypnoTime
//
//  Created by Radek Skokan on 5/17/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        UITabBarItem *tbi = [self tabBarItem];
        [tbi setTitle:@"Map"];
    }
    
    return self;
}

- (void)loadView
{
    NSLog(@"MapViewController loadView");
    CGRect frame = [[UIScreen mainScreen] bounds];
    MKMapView *v = [[MKMapView alloc] initWithFrame:frame];
    [self setView:v];
}

@end
