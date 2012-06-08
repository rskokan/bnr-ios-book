//
//  TouchDrawView.m
//  TouchTracker
//
//  Created by Radek Skokan on 5/24/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import "TouchDrawView.h"
#import "Line.h"

@implementation TouchDrawView

@synthesize selectedLine;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        linesInProcess = [[NSMutableDictionary alloc] init];
        completeLines = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setMultipleTouchEnabled:YES];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        [moveRecognizer setDelegate:self];
        [moveRecognizer setCancelsTouchesInView:NO];
        [self addGestureRecognizer:moveRecognizer];
    }
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == moveRecognizer) {
        return YES;
    } else {
        return NO;
    }
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 10.0);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    // Draw complete lines in black
    [[UIColor blueColor] set];
    for (Line *line in completeLines) {
        CGContextMoveToPoint(ctx, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(ctx, [line end].x, [line end].y);
        CGContextStrokePath(ctx);
    }
    
    // Draw lines in process in red
    [[UIColor redColor] set];
    for (NSValue *k in linesInProcess) {
        Line *line = [linesInProcess objectForKey:k];
        CGContextMoveToPoint(ctx, [line begin].x, [line begin].y);
        CGContextAddLineToPoint(ctx, [line end].x, [line end].y);
        CGContextStrokePath(ctx);
    }
    
    // If there is a selected line, draw it in green
    if ([self selectedLine]) {
        [[UIColor greenColor] set];
        CGContextMoveToPoint(ctx, [[self selectedLine] begin].x, [[self selectedLine] begin].y);
        CGContextAddLineToPoint(ctx, [[self selectedLine] end].x, [[self selectedLine] end].y);
        CGContextStrokePath(ctx);
    }
}


- (void)clearAll
{
    [completeLines removeAllObjects];
    [linesInProcess removeAllObjects];
    
    [self setNeedsDisplay];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        // Is this a double tap?
        if ([t tapCount] > 1) {
            [self clearAll];
        }
        
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        
        CGPoint loc = [t locationInView:self];
        Line *line = [[Line alloc] init];
        [line setBegin:loc];
        [line setEnd:loc];
        
        [linesInProcess setObject:line forKey:key];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Update linesInProcess with moved touches
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        // Update the line
        CGPoint loc = [t locationInView:self];
        [line setEnd:loc];
    }
    
    [self setNeedsDisplay];
}


- (void)endTouches:(NSSet *)touches
{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        Line *line = [linesInProcess objectForKey:key];
        
        // If this is a double tap, line will be nil
        if (line) {
            [completeLines addObject:line];
            [linesInProcess removeObjectForKey:key];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches];
}


- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Tap recognized");
    CGPoint point = [gr locationInView:self];
    [self setSelectedLine:[self lineAtPoint:point]];
    
    [linesInProcess removeAllObjects];
    
    if ([self selectedLine]) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        [menu setMenuItems:[NSArray arrayWithObject:deleteItem]];
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}


- (void)longPress:(UIGestureRecognizer *)gr
{
    if ([gr state] == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        [self setSelectedLine:[self lineAtPoint:point]];
        
        if ([self selectedLine]) {
            [linesInProcess removeAllObjects];
        }
    } else if ([gr state] == UIGestureRecognizerStateEnded) {
        [self setSelectedLine:nil];
    }
    
    [self setNeedsDisplay];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)deleteLine:(id)sender
{
    [completeLines removeObject:[self selectedLine]];
    [self setNeedsDisplay];
}


- (Line *)lineAtPoint:(CGPoint)point
{
    // Find a line close to point
    for (Line *l in completeLines) {
        CGPoint start = [l begin];
        CGPoint end = [l end];
        
        for (float t = 0.0; t < 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            if (hypot(x - point.x, y - point.y) < 20.0) {
                NSLog(@"Found selected line");
                return l;
            }
        }
    }
    
    NSLog(@"No selected line found");
    return nil;
}


- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    if (![self selectedLine])
        return;
    
    if ([gr state] == UIGestureRecognizerStateChanged) {
        // How far has the pan moved?
        CGPoint translation = [gr translationInView:self];
        CGPoint begin = [[self selectedLine] begin];
        CGPoint end = [[self selectedLine] end];
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        [[self selectedLine] setBegin:begin];
        [[self selectedLine] setEnd:end];
        
        [self setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:self];
    }
}


- (int)numberOfLines
{
    int count = 0;
    
    if (linesInProcess && completeLines) {
        count = [linesInProcess count] + [completeLines count];
    }
    
    return count;
}

@end
