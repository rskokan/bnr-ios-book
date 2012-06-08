//
//  QuizViewController.h
//  Quiz
//
//  Created by Radek Skokan on 5/14/12.
//  Copyright (c) 2012 radek@skokan.name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizViewController : UIViewController
{
    int currentQuestionIndex;
    
    // Model objects
    NSMutableArray *questions;
    NSMutableArray *answers;
    
    // View objects
    IBOutlet UILabel *questionField;
    IBOutlet UILabel *answerField;
}

- (IBAction)showQuestion:(id)sender;
- (IBAction)showAnswer:(id)sender;

@end
