//
//  WebViewController.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "WebViewController.h"
#import "RSSItem.h"

@implementation WebViewController

- (void)loadView
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    UIWebView *wv = [[UIWebView alloc] initWithFrame:screenFrame];
    [wv setScalesPageToFit:YES];
    [self setView:wv];
}

- (UIWebView *) webView
{
    return (UIWebView *)[self view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)listViewController:(ListViewController *)lvc hadleObject:(id)obj
{
    RSSItem *item = obj;
    if (![item isKindOfClass:[RSSItem class]])
        return;
    
    NSURL *url = [NSURL URLWithString:[item link]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:req];
    [[self navigationItem] setTitle:[item title]];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"List"];
    [[self navigationItem] setLeftBarButtonItem:barButtonItem];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if (barButtonItem == [[self navigationItem] leftBarButtonItem]) {
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
}

@end
