//
//  BNRMapPoint.m
//  Whereami
//
//  Created by Radek Skokan on 5/15/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRMapPoint.h"

@implementation BNRMapPoint

@synthesize coordinate, title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t
{
    self = [super init];
    if (self) {
        NSDate *now = [NSDate date];
        NSString *currentDateAsString = [NSDateFormatter localizedStringFromDate:now
                                                                       dateStyle:NSDateFormatterMediumStyle
                                                                       timeStyle:NSDateFormatterMediumStyle];
        NSString *titleWithDate = [[NSString alloc] initWithFormat:@"%@ (recorded on %@)", t, currentDateAsString];
        
        coordinate = c;
        [self setTitle:titleWithDate];
    }
    
    return self;
}

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(+50.053, +14.418) title:@"Home"];
}

@end
