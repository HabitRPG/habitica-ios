//
//  HRPGTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 04/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "UIViewController+Markdown.h"
#import "Habitica-Swift.h"

@implementation UIViewController (Markdown)

- (NSMutableAttributedString *)renderMarkdown:(NSString *)text {
    return [HabiticaMarkdownHelper toHabiticaAttributedString:text error:nil];
}

@end
