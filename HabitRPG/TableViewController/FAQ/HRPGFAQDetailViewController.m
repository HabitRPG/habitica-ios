//
//  HRPGFAQDetailTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGFAQDetailViewController.h"
#import <CoreText/CoreText.h>
#import "UIViewController+Markdown.h"

@interface HRPGFAQDetailViewController ()
@property NSMutableDictionary *attributes;
@end

@implementation HRPGFAQDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureMarkdownAttributes];
    
    self.questionLabel.text = self.faq.question;
    self.answerTextView.attributedText = [self renderMarkdown:[self.faq getRelevantAnswer]];
    self.answerTextView.textContainerInset = UIEdgeInsetsMake(0, 16, 16, 16);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.answerTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

@end
