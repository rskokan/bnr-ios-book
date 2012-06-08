//
//  ItemsViewController.h
//  Homepwner
//
//  Created by Radek Skokan on 5/18/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"

@interface ItemsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
{
    UIPopoverController *imagePopover;
}

- (IBAction)addNewItem:(id)sender;

@end
