//
//  HypnosisterAppDelegate.h
//  Hypnosister
//
//  Created by Radek Skokan on 5/16/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HypnosisView.h"

@interface HypnosisterAppDelegate : UIResponder <UIApplicationDelegate, UIScrollViewDelegate>
{
    HypnosisView *view;
}

@property (strong, nonatomic) UIWindow *window;

@end
