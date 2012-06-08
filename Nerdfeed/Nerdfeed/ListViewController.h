//
//  ListViewController.h
//  Nerdfeed
//
//  Created by Radek Skokan on 5/26/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSChannel;
@class WebViewController;

typedef enum {
    ListViewControllerRSSTypeBNR,
    ListViewControllerRSSTypeApple
} ListViewControllerRSSType;

@interface ListViewController : UITableViewController <NSXMLParserDelegate>
{
    RSSChannel *channel;
    ListViewControllerRSSType rssType;
}

@property (nonatomic, strong) WebViewController *webViewController;

@end



@protocol ListViewControllerDelegate

- (void)listViewController:(ListViewController *)lvc hadleObject:(id) obj;

@end