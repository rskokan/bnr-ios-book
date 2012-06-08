//
//  BNRMapPoint.h
//  Whereami
//
//  Created by Radek Skokan on 5/15/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BNRMapPoint : NSObject <MKAnnotation>
{
    
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

@end
