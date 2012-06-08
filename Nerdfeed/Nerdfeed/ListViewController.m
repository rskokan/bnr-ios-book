//
//  ListViewController.m
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "LogDef.h"
#import "WebViewController.h"
#import "ChannelViewController.h"
#import "BNRFeedStore.h"

@implementation ListViewController

@synthesize webViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Register for notifs from the Store that it merged new data from iCloud
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(storeUpdated:)
                                                     name:BNRFeedStoreUpdateNotification
                                                   object:nil];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"Info"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(showInfo:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        
        UISegmentedControl *rssTypeControl = [[UISegmentedControl alloc] initWithItems:
                                              [NSArray arrayWithObjects:@"BNR", @"Apple", nil]];
        [rssTypeControl setSelectedSegmentIndex:0];
        [rssTypeControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [rssTypeControl addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventValueChanged];
        [[self navigationItem] setTitleView:rssTypeControl];
        
        [self fetchEntries];
    }
    
    return self;
}

- (void)storeUpdated:(NSNotification *)notif
{
    [[self tableView] reloadData];
}

- (void)changeType:(id)sender
{
    rssType = [sender selectedSegmentIndex];
    [self fetchEntries];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[item title]];
    
    if ([[BNRFeedStore sharedStore] hasItemBeenRead:item]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)fetchEntries
{
    // Start animation while fetching data
    UIView *savedTitleView = [[self navigationItem] titleView];
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [[self navigationItem] setTitleView:aiView];
    [aiView startAnimating];
    
    void (^completionBlock)(RSSChannel *ch, NSError *err) = ^(RSSChannel *ch, NSError *err) {
        NSLog(@"Completion block called");
        // Stop fetching animation
        [[self navigationItem] setTitleView:savedTitleView];
        
        if (!err) {
            channel = ch;
            [[self tableView] reloadData];
        } else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:[err localizedDescription]
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
            [av show];
        }
    };
    
    if (rssType == ListViewControllerRSSTypeBNR) {
        channel = [[BNRFeedStore sharedStore] fetchRSSFeedWithCompletion:
                   ^(RSSChannel *ch, NSError *err) {
                       [[self navigationItem] setTitleView:savedTitleView];
                       
                       if (!err) {
                           int currentItemCount = [[channel items] count];
                           channel = ch;
                           int newItemsCount = [[channel items] count];
                           int itemDelta = newItemsCount - currentItemCount;
                           if (itemDelta > 0) {
                               NSMutableArray *rows = [NSMutableArray array];
                               for (int i = 0; i < itemDelta; i++) {
                                   NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                                   [rows addObject:ip];
                               }
                               
                               [[self tableView] insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
                           }
                           
                       }
                   }];
        [[self tableView] reloadData];
        
    } else if (rssType == ListViewControllerRSSTypeApple) {
        [[BNRFeedStore sharedStore] fetchTopSongs:20 withCompletion:completionBlock];
    }
    
    NSLog(@"At the end of fetchEntries");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self splitViewController]) {
        [[self navigationController] pushViewController:webViewController animated:YES];
    } else {
        UINavigationController *navWeb = [[UINavigationController alloc] initWithRootViewController:webViewController];
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], navWeb, nil];
        [[self splitViewController] setViewControllers:vcs];
        [[self splitViewController] setDelegate:webViewController];
    }
    
    RSSItem *item = [[channel items] objectAtIndex:[indexPath row]];
    
    [[BNRFeedStore sharedStore] markItemAsRead:item];
    [[[self tableView] cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [webViewController listViewController:self hadleObject:item];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    }
    
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showInfo:(id)sender
{
    ChannelViewController *channVC = [[ChannelViewController alloc] initWithStyle:UITableViewStyleGrouped];
    if ([self splitViewController]) {
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:channVC];
        NSArray *vcs = [NSArray arrayWithObjects:[self navigationController], nvc, nil];
        [[self splitViewController] setViewControllers:vcs];
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        if (selectedRow) {
            [[self tableView] deselectRowAtIndexPath:selectedRow animated:YES];
        }
    } else {
        [[self navigationController] pushViewController:channVC animated:YES];
    }
    
    [channVC listViewController:self hadleObject:channel];
}

@end
