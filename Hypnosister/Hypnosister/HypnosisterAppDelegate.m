//
//  HypnosisterAppDelegate.m
//  Hypnosister
//
//  Created by Radek Skokan on 5/16/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "HypnosisterAppDelegate.h"
#import "HypnosisView.h"

@implementation HypnosisterAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    CGRect screenRect = [[self window] bounds];
    UIScrollView *scrolLView = [[UIScrollView alloc] initWithFrame:screenRect];
//    [scrolLView setPagingEnabled:YES];
    [scrolLView setMinimumZoomScale:1.0];
    [scrolLView setMaximumZoomScale:5.0];
    
    [scrolLView setDelegate:self];
    
    [[self window] addSubview:scrolLView];
    
    CGRect bigRect = screenRect;
//    bigRect.size.width *= 2;
//    bigRect.size.height *= 2;
    
    view = [[HypnosisView alloc] initWithFrame:screenRect];
//        HypnosisView *view = [[HypnosisView alloc] initWithFrame:bigRect];
//    [[self window] addSubview:view];
    [scrolLView addSubview:view];
                         
//    screenRect.origin.x = screenRect.size.width; // move horizontally to next  screen
//    HypnosisView *view2 = [[HypnosisView alloc] initWithFrame:screenRect];
//    [view2 setCircleColor:[UIColor darkGrayColor]];
//    [scrolLView addSubview:view2];
                          
    [scrolLView setContentSize:bigRect.size];
    
    // Become first responder to react on shake
    BOOL success = [view becomeFirstResponder];
    if (success) {
        NSLog(@"HypnosisView became the first responder");
    } else {
        NSLog(@"HypnosisView couldn't became the first responder");
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return view;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
