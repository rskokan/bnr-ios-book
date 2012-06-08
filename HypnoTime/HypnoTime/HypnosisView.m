//
//  HypnosisView.m
//  Hypnosister
//
//  Created by Radek Skokan on 5/16/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "HypnosisView.h"

@implementation HypnosisView

@synthesize circleColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        boxLayer = [[CALayer alloc] init];
        [boxLayer setBounds:CGRectMake(0.0, 0.0, 85.0, 85.0)];
        [boxLayer setPosition:CGPointMake(160.0, 100.0)];
        UIColor *reddish = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        [boxLayer setBackgroundColor:[reddish CGColor]];
        
        UIImage *layerImage = [UIImage imageNamed:@"Hypno.png"];
        CGImageRef image = [layerImage CGImage];
        [boxLayer setContents:(__bridge id)image];
        [boxLayer setContentsRect:CGRectMake(-0.1, -0.1, 1.2, 1.2)];
        // Resize the image to fill the contentRect
        [boxLayer setContentsGravity:kCAGravityResizeAspect];
        
        [[self layer] addSublayer:boxLayer];
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = [self bounds];
    
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2;
    center.y = bounds.origin.y + bounds.size.height / 2;
    
    float maxRadius = hypot(bounds.size.width, bounds.size.height) / 2;
    
    CGContextSetLineWidth(ctx, 10);
    //    CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.6, 1.0);
    //    [[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0] setStroke];
//    [[self circleColor] setStroke];
    [[UIColor lightGrayColor] set];
    for (float currentRadius = maxRadius; currentRadius > 0; currentRadius -= 20) {
        CGContextAddArc(ctx, center.x, center.y, currentRadius, 0.0, M_PI * 2.0, YES);
        CGContextStrokePath(ctx);
    }
    
    // Draw a text
    NSString *sleepyText = @"You are getting sleepy";
    UIFont *font = [UIFont boldSystemFontOfSize:28];
    CGRect textRect;
    textRect.size = [sleepyText sizeWithFont:font];
    textRect.origin.x = center.x - textRect.size.width / 2.0;
    textRect.origin.y = center.y - textRect.size.height / 2.0;
    [[UIColor blackColor] setFill];
    
    // Make a shadow
    CGSize offset = CGSizeMake(4, 3);
    CGColorRef color = [[UIColor darkGrayColor] CGColor];
    // Since now on, all subsequent drawings will be shadowed
    CGContextSetShadowWithColor(ctx, offset, 2.0, color);
    
    [sleepyText drawInRect:textRect withFont:font];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];
    [boxLayer setPosition:p];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:self];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [boxLayer setPosition:p];
    [CATransaction commit];
}

@end
