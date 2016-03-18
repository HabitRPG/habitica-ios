//
//  HRPGCopyLabel.m
//  Habitica
//
//  Created by Phillip Thelen on 21/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCopyLabel.h"

@implementation HRPGCopyLabel

- (void)attachTapHandler {
    [self setUserInteractionEnabled:YES];
    UIGestureRecognizer *gestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:gestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self attachTapHandler];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self attachTapHandler];
}

#pragma mark Clipboard

- (void)copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
