//
//  ChannelViewController.h
//  Nerdfeed
//
//  Created by Radek Skokan on 5/28/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListViewController.h"

@interface ChannelViewController : UITableViewController <ListViewControllerDelegate, UISplitViewControllerDelegate>
{
    RSSChannel *channel;
}

@end
