//
//  DetailViewController.m
//  Homepwner
//
//  Created by Radek Skokan on 5/20/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "AssetTypePicker.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize item, dismissBlock;


- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self) {
        if (isNew) {
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                         target:self
                                         action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                           target:self
                                           action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        }
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"Use initForNewItem:" userInfo:nil];
    return nil;
}


- (void)save:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}


- (void)cancel:(id)sender
{
    [[BNRItemStore sharedStore] removeItem:item];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:dismissBlock];
}


- (void)setItem:(BNRItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[item itemName]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *clr;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        clr = [UIColor colorWithRed:0.875 green:0.88 blue:0.91 alpha:1.0];
    } else {
        clr = [UIColor groupTableViewBackgroundColor];
    }
    
    [[self view] setBackgroundColor:clr];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [nameField setText:[item itemName]];
    [serialNumberField setText:[item serialNumber]];
    [valueField setText:[NSString stringWithFormat:@"%d", [item valueInDollars]]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[item dateCreated]];
    [dateLabel setText:[dateFormatter stringFromDate:date]];
    
    NSString *imageKey = [item imageKey];
    if (imageKey) {
        UIImage *image = [[BNRImageStore sharedStore] imageForKey:imageKey];
        [imageView setImage:image];
    } else {
        [imageView setImage:nil];
    }
    
    NSString *typeLabel = [[item assetType] valueForKey:@"label"];
    if (!typeLabel)
        typeLabel = @"None";
    
    [assetTypeButton setTitle:[NSString stringWithFormat:@"Type: %@", typeLabel] forState:UIControlStateNormal];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear first responder (hide keyboard)
    [[self view] endEditing:YES];
    
    [item setItemName:[nameField text]];
    [item setSerialNumber:[serialNumberField text]];
    [item setValueInDollars:[[valueField text] intValue]];
}


- (void)viewDidUnload {
    nameField = nil;
    serialNumberField = nil;
    valueField = nil;
    dateLabel = nil;
    imageView = nil;
    assetTypeButton = nil;
    [super viewDidUnload];
}


- (IBAction)takePicture:(id)sender {
    if ([imagePickerPopover isPopoverVisible]) {
        // On another camera-button click, dismiss the popover if already displayed
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    
    // Check if the device has a camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePickerPopover setDelegate:self];
        [imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES]; 
}


- (IBAction)deletePhoto:(id)sender
{
    NSString *oldImageKey = [item imageKey];
    if (oldImageKey) {
        [[BNRImageStore sharedStore] deleteImageForKey:oldImageKey];
    }
    [item setImageKey:nil];
    [imageView setImage:nil];
}


- (IBAction)showAssetTypePicker:(id)sender
{
    [[self view] endEditing:YES];
    
    AssetTypePicker *picker = [[AssetTypePicker alloc] init];
    [picker setItem:item];
    
    [[self navigationController] pushViewController:picker animated:YES];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSString *oldImageKey = [item imageKey];
    if (oldImageKey) {
        [[BNRImageStore sharedStore] deleteImageForKey:oldImageKey];
    }
    
    CFUUIDRef imageIdRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef imageIdStrRef = CFUUIDCreateString(kCFAllocatorDefault, imageIdRef);
    NSString *imageId = (__bridge NSString *) imageIdStrRef;
    [item setImageKey:imageId];
    [[BNRImageStore sharedStore] setImage:image forKey:imageId];
    CFRelease(imageIdRef);
    CFRelease(imageIdStrRef);
    
    [item setThumbnailDataFromImage:image];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // on iPhone, dismiss the modally presented image picker
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // on iPad, dismiss the popover
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSLog(@"User dismissed popover");
    popoverController = nil;
}


@end
