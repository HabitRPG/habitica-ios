//
//  HRPGExplanationView.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGExplanationView.h"
#import "HRPGSpeechBubbleView.h"
#import "HRPGHoledView.h"

@interface HRPGExplanationView ()

@property UIView *displayView;

@property UIImageView *justinView;
@property HRPGSpeechbubbleView *speechBubbleView;
@property HRPGHoledView *backgroundView;
@end

@implementation HRPGExplanationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        self.backgroundView = [[HRPGHoledView alloc] init];
        self.backgroundView.dimColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.backgroundView.alpha = 0;
        [self addSubview:self.backgroundView];

        self.justinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"justin"]];
        self.justinView.userInteractionEnabled = NO;
        [self addSubview:self.justinView];

        self.speechBubbleView = [[HRPGSpeechbubbleView alloc] init];
        self.speechBubbleTextColor = [UIColor blackColor];
        [self addSubview:self.speechBubbleView];

        UIGestureRecognizer *gestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:gestureRecognizer];
    }

    return self;
}

- (void)displayHintOnView:(UIView *)view
          withDisplayView:(UIView *)displayView
                 animated:(BOOL)animated {
    self.displayView = displayView;
    self.hintView = [[HRPGHintView alloc] init];
    self.hintView.frame = CGRectMake(
        self.highlightedFrame.origin.x + ((self.highlightedFrame.size.width - 45) / 2),
        self.highlightedFrame.origin.y + ((self.highlightedFrame.size.height - 45) / 2), 45, 45);
    UIGestureRecognizer *gestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHintTap:)];
    [self.hintView addGestureRecognizer:gestureRecognizer];
    [self.hintView pulseToSize:1.4 withDuration:1.0];

    [view addSubview:self.hintView];
}

- (void)displayOnView:(UIView *)view animated:(BOOL)animated {
    [view addSubview:self];
    self.frame = view.frame;
    self.backgroundView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    CGFloat speechBubbleWidth = self.frame.size.width - 80;
    CGFloat xOffset = 10;
    if (speechBubbleWidth > 500) {
        speechBubbleWidth = 500;
        xOffset = (self.frame.size.width - 560) / 2;
    }
    CGRect boundingRect = [self.speechBubbleText
        boundingRectWithSize:CGSizeMake(speechBubbleWidth - 28, MAXFLOAT)
                     options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:@{
                      NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                  }
                     context:nil];
    CGFloat speechBubbleHeight = boundingRect.size.height + 100;
    self.justinView.frame = CGRectMake(xOffset, self.frame.size.height, 48, 63);
    self.speechBubbleView.frame = CGRectMake(xOffset + 50, self.frame.size.height - 20, 0, 0);
    self.speechBubbleView.alpha = 0;
    [UIView animateWithDuration:0.4
        animations:^() {
            self.backgroundView.alpha = 1;
        }
        completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4
                animations:^() {
                    self.justinView.frame =
                        CGRectMake(xOffset, self.frame.size.height - 50, 42, 63);
                }
                completion:^(BOOL completed) {
                    [UIView animateWithDuration:0.3
                        animations:^() {
                            self.speechBubbleView.alpha = 1.0;
                            self.speechBubbleView.frame = CGRectMake(
                                xOffset + 50, self.frame.size.height - speechBubbleHeight - 20,
                                speechBubbleWidth, speechBubbleHeight);
                        }
                        completion:^(BOOL completed) {
                            self.speechBubbleView.text = self.speechBubbleText;
                        }];
                }];
        }];
}

- (void)dismissAnimated:(BOOL)animated wasSeen:(BOOL)wasSeen {
    self.displayView = nil;
    if (self.dismissAction) {
        self.dismissAction(wasSeen);
    }
    [UIView animateWithDuration:0.4
        animations:^() {
            self.alpha = 0;
        }
        completion:^(BOOL completed) {
            [self removeFromSuperview];

        }];
}

- (void)setSpeechBubbleTextColor:(UIColor *)speechBubbleTextColor {
    _speechBubbleTextColor = speechBubbleTextColor;
    self.speechBubbleView.textColor = speechBubbleTextColor;
}

- (void)setHighlightedFrame:(CGRect)highlightedFrame {
    _highlightedFrame = highlightedFrame;
    self.backgroundView.highlightedFrame = highlightedFrame;
    [self.backgroundView setNeedsDisplay];
}

- (void)handleHintTap:(UIGestureRecognizer *)recognizer {
    [self.hintView removeFromSuperview];
    [self displayOnView:self.displayView animated:YES];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [self dismissAnimated:YES wasSeen:YES];
}

- (void)removeFromSuperview {
    if (self.hintView) {
        [self.hintView removeFromSuperview];
    }
    [super removeFromSuperview];
}

@end
