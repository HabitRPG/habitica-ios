//
//  HRPGFAQDetailTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGFAQDetailViewController.h"
#import "UIViewController+Markdown.h"
#import "HRPGTopHeaderNavigationController.h"

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

    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController =
            (HRPGTopHeaderNavigationController *)self.navigationController;
        if (navigationController.state != HRPGTopHeaderStateHidden) {
            [navigationController scrollview:nil scrolledToPosition:0];
        }
    }
}

@end
