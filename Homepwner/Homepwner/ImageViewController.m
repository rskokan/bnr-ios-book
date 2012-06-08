//
//  ImageViewController.m
//  Homepwner
//
//  Created by Radek Skokan on 5/22/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "ImageViewController.h"
#import "BNRImageStore.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

@synthesize image;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGSize size = [image size];
    [scrollView setContentSize:size];
    [imageView setFrame:CGRectMake(0, 0, size.width, size.height)];
    [imageView setImage:image];
}

@end
