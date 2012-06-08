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
        [self setCircleColor:[self makeRandomColor]];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventTypeMotion) {
        NSLog(@"Shaking ass");
//        [self setCircleColor:[UIColor redColor]];
        [self setNeedsDisplay];
    }
}

//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (motion == UIEventTypeMotion) {
//        NSLog(@"Shaking ass ended");
//        [self setCircleColor:[UIColor lightGrayColor]];
//    }
//}

- (void)setCircleColor:(UIColor *)clr
{
    circleColor = clr;
    [self setNeedsDisplay];
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
    
    for (float currentRadius = maxRadius; currentRadius > 0; currentRadius -= 20) {
        [[self makeRandomColor] setStroke];
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

- (UIColor *)makeRandomColor
{
    CGFloat red = (rand() % 10) / 10.0;
    CGFloat green = (rand() % 10) / 10.0;
    CGFloat blue = (rand() % 10) / 10.0;
    NSLog(@"Random color: R=%f, G=%f, B=%f", red, green, blue);
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
