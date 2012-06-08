//
//  WhereamiViewController.h
//  Whereami
//
//  Created by Radek Skokan on 5/15/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "BNRMapPoint.h"

@interface WhereamiViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    
    IBOutlet MKMapView *worldView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITextField *locationTextField;
    __weak IBOutlet UISegmentedControl *mapTypeControl;
}

- (void)findLocation;
- (void)foundLocation:(CLLocation *)loc;

- (IBAction)changeMapType:(UISegmentedControl *)mapTypeSelector;

@end
