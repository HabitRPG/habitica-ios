//
//  HRPGTableViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 04/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Markdown)

- (void)configureMarkdownAttributes;

- (NSMutableAttributedString *)renderMarkdown:(NSString *)text;

@property NSMutableDictionary *attributes;

@end
