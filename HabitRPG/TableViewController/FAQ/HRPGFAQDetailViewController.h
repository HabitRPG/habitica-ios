//
//  HRPGFAQDetailTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAQ.h"
#import "HRPGUIViewController.h"

@interface HRPGFAQDetailViewController : HRPGUIViewController

@property FAQ *faq;
@property(weak, nonatomic) IBOutlet UILabel *questionLabel;
@property(weak, nonatomic) IBOutlet UITextView *answerTextView;

@end
