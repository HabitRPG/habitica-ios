//
//  HRPGFAQDetailTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAQ.h"

@interface HRPGFAQDetailViewController : UIViewController

@property FAQ *faq;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerTextView;

@end
