//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Radek Skokan on 5/18/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "BNRItem.h"
#import "HomepwnerItemCell.h"
#import "ImageViewController.h"

@implementation ItemsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        UINavigationItem *ni = [self navigationItem];
        [ni setTitle:NSLocalizedString(@"Homepwner", @"Name of the app")];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        [[self navigationItem] setRightBarButtonItem:bbi];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"HomepwnerItemCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"HomepwnerItemCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNRItem *item = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    
    HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
    [[cell nameLabel] setText:[item itemName]];
    [[cell serialNumberLabel] setText:[item serialNumber]];
    NSString *currencySymbol = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    [[cell valueLabel] setText:[NSString stringWithFormat:@"%@%d", currencySymbol, [item valueInDollars]]];
    [[cell thumbnailView] setImage:[item thumbnail]];
    
    [cell setController:self];
    [cell setTableView:tableView];
    
    return cell;
}


- (IBAction)addNewItem:(id)sender
{
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    DetailViewController *dvc = [[DetailViewController alloc] initForNewItem:YES];
    [dvc setItem:newItem];
    [dvc setDismissBlock:^{
        [[self tableView] reloadData];
    }];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dvc];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        BNRItemStore *store = [BNRItemStore sharedStore];
        NSArray *items = [store allItems];
        BNRItem *item = [items objectAtIndex:[indexPath row]];
        [store removeItem:item];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemAtIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *items = [[BNRItemStore sharedStore] allItems];
    BNRItem *item = [items objectAtIndex:[indexPath row]];
    
    DetailViewController *dvc = [[DetailViewController alloc] initForNewItem:NO];
    [dvc setItem:item];
    [[self navigationController] pushViewController:dvc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}


- (void)showImage:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        BNRItem *item = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
        NSString *imageKey = [item imageKey];
        UIImage *image = [[BNRImageStore sharedStore] imageForKey:imageKey];
        
        if (!image)
            return;
        
        CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
        ImageViewController *ivc = [[ImageViewController alloc] init];
        [ivc setImage:image];
        
        imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
        [imagePopover setDelegate:self];
        [imagePopover setPopoverContentSize:CGSizeMake(600, 600)];
        [imagePopover presentPopoverFromRect:rect
                                      inView:[self view]
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [imagePopover dismissPopoverAnimated:YES];
    imagePopover = nil;
}

@end
