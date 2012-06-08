//
//  WebViewController.h
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface WebViewController : UIViewController <ListViewControllerDelegate, UISplitViewControllerDelegate>

@property (nonatomic, readonly) UIWebView *webView;

@end
