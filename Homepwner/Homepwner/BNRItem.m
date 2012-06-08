//
//  BNRItem.m
//  Homepwner
//
//  Created by Radek Skokan on 5/23/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "BNRItem.h"


@implementation BNRItem

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic imageKey;
@dynamic thumbnailData;
@dynamic thumbnail;
@dynamic orderingValue;
@dynamic assetType;


- (void)awakeFromFetch
{
    [super awakeFromFetch];
    UIImage *thumbnail = [UIImage imageWithData:[self thumbnailData]];
    [self setPrimitiveValue:thumbnail forKey:@"thumbnail"];
}


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    NSTimeInterval ti = [[NSDate date] timeIntervalSinceReferenceDate];
    [self setDateCreated:ti];
}


- (void)setThumbnailDataFromImage:(UIImage *)image
{
    CGSize origImageSize = [image size];
    
    CGRect newRect = CGRectMake(0, 0, 40, 40);
    
    // Figure out a scaling atio so that we maintain the original aspect ratio
    float ratio = MAX(newRect.size.width / origImageSize.width, newRect.size.height / origImageSize.height);
    
    // Create a transparent bitmap context
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    // Create a rounded rectangle path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    // Make all subsequent drawing clip to this rectangle
    [path addClip];
    
    // Center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2;
    
    [image drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:smallImage];
    [self setThumbnailData:UIImagePNGRepresentation(smallImage)];
    
    // Clean up the temporary image context
    UIGraphicsEndImageContext();
}

@end
