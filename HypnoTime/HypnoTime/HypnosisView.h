//
//  HypnosisView.h
//  Hypnosister
//
//  Created by Radek Skokan on 5/16/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface HypnosisView : UIView
{
    CALayer *boxLayer;
}

@property (nonatomic, strong) UIColor *circleColor;

@end
