//
//  HRPGFAQDetailTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFAQDetailViewController.h"
#import "UIViewController+Markdown.h"
#import "UIViewController+HRPGTopHeaderNavigationController.h"
#import "Habitica-Swift.h"

@interface HRPGFAQDetailViewController ()
@end

@implementation HRPGFAQDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topHeaderCoordinator.hideHeader = true;

    self.questionLabel.text = self.faq.question;
    self.answerTextView.attributedText = [self renderMarkdown:[self.faq getRelevantAnswer]];
    self.answerTextView.textContainerInset = UIEdgeInsetsMake(0, 16, 16, 16);
}

@end
