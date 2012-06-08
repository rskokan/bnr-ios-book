//
//  WhereamiViewController.m
//  Whereami
//
//  Created by Radek Skokan on 5/15/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "WhereamiViewController.h"

NSString * const WhereamiMapTypePrefKey = @"WhereamiMapTypePrefKey";

@implementation WhereamiViewController

+ (void)initialize
{
    NSDictionary *defaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:WhereamiMapTypePrefKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [locationManager setDistanceFilter:5]; // at least 2 meters change
//        [locationManager startUpdatingLocation];
//        
//        if ([CLLocationManager headingAvailable]) {
//            [locationManager setHeadingFilter:1]; // at least 1 degree change
//            [locationManager startUpdatingHeading];
//        } else {
//            NSLog(@"This device does not support heading direction (no compass)");
//        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [worldView setShowsUserLocation:YES];
    
    NSInteger mapTypeValue = [[NSUserDefaults standardUserDefaults] integerForKey:WhereamiMapTypePrefKey];
    [mapTypeControl setSelectedSegmentIndex:mapTypeValue];
    [self changeMapType:mapTypeControl];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D loc = [userLocation coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [worldView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"#newLocation=%@", newLocation);
    
    // Is it actual location? Ignore cached, older than 3 minutes
    NSTimeInterval age = [[newLocation timestamp] timeIntervalSinceNow];
    if (age < -180) {
        return;
    }
    
    [self foundLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"We are now heading %@", newHeading);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Cannot determine current location: %@", error);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self findLocation];
    [textField resignFirstResponder];
    return YES;
}

- (void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTextField setHidden:YES];
}

- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    BNRMapPoint *point = [[BNRMapPoint alloc] initWithCoordinate:coord title:[locationTextField text]];
    [worldView addAnnotation:point];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [worldView setRegion:region animated:YES];
    
    [locationTextField setText:@""];
    [activityIndicator stopAnimating];
    [locationTextField setHidden:NO];
    
    [locationManager stopUpdatingLocation];
}

- (IBAction)changeMapType:(UISegmentedControl *)mapTypeSelector
{
    int selectedMapIdx = [mapTypeSelector selectedSegmentIndex];
    NSLog(@"Selected map type index has changed to %d", selectedMapIdx);
    
    [[NSUserDefaults standardUserDefaults] setInteger:selectedMapIdx forKey:WhereamiMapTypePrefKey];
    
    MKMapType mapType;
    switch (selectedMapIdx) {
        case 0:
            mapType = MKMapTypeStandard;
            break;
        case 1:
            mapType = MKMapTypeSatellite;
            break;
        case 2:
            mapType = MKMapTypeHybrid;
            break;
    }
    [worldView setMapType:mapType];
}

- (void)dealloc
{
    // release all delegated objects
    [locationManager setDelegate:nil];
    [worldView setDelegate:nil];
}

     - (void)viewDidUnload {
         mapTypeControl = nil;
         [super viewDidUnload];
     }
@end
