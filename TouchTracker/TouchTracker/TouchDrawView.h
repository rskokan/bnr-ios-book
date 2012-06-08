//
//  TouchDrawView.h
//  TouchTracker
//
//  Created by Radek Skokan on 5/24/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Line;

@interface TouchDrawView : UIView <UIGestureRecognizerDelegate>
{
    NSMutableDictionary *linesInProcess;
    NSMutableArray *completeLines;
    
    UIPanGestureRecognizer *moveRecognizer;
}

@property (nonatomic, weak) Line *selectedLine;

- (Line *)lineAtPoint:(CGPoint)point;

- (void)clearAll;
- (void)endTouches:(NSSet *)touches;

@end
