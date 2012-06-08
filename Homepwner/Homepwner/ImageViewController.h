//
//  ImageViewController.h
//  Homepwner
//
//  Created by Radek Skokan on 5/22/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController <UIPopoverControllerDelegate>
{
    
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *imageView;
}

@property (nonatomic, strong) UIImage *image;

@end
