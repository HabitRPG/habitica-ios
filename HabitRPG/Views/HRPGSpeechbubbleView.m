//
//  HRPGSpeechbubbleView.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGSpeechbubbleView.h"
#import "HRPGTypingLabel.h"
#import "UIColor+Habitica.h"
#import "HRPGExplanationView.h"

@interface HRPGSpeechbubbleView ()

@property HRPGTypingLabel *textLabel;
@property UIButton *dismissButton;
@property UIButton *remindAgainButton;
@property UIImageView *backgroundView;
@end

@implementation HRPGSpeechbubbleView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"speech_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 40, 28, 12)]];
        [self addSubview:self.backgroundView];
        self.textLabel = [[HRPGTypingLabel alloc] init];
        __weak HRPGSpeechbubbleView *weakSelf = self;
        self.textLabel.finishedAction = ^() {
            [weakSelf displayButtons];
        };
        [self addSubview:self.textLabel];
        self.dismissButton = [[UIButton alloc] init];
        [self.dismissButton setTitle:NSLocalizedString(@"Got it", nil) forState:UIControlStateNormal];
        [self.dismissButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
        self.dismissButton.alpha = 0;
        [self.dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.dismissButton];
        self.remindAgainButton = [[UIButton alloc] init];
        [self.remindAgainButton setTitle:NSLocalizedString(@"Remind me tomorrow", nil) forState:UIControlStateNormal];
        [self.remindAgainButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
        self.remindAgainButton.alpha = 0;
        [self.remindAgainButton addTarget:self action:@selector(remindAgainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.remindAgainButton];
        self.textColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.dismissButton.frame = CGRectMake(8, frame.size.height-54, frame.size.width-16, 30);
    self.remindAgainButton.frame = CGRectMake(8, self.dismissButton.frame.origin.y-38, frame.size.width-16, 30);
    self.textLabel.frame = CGRectMake(8, 0, frame.size.width-16, self.remindAgainButton.frame.origin.y);
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLabel.textColor = textColor;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textLabel.text = text;
}

- (void)displayButtons {
    [UIView animateWithDuration:0.3 animations:^() {
        self.remindAgainButton.alpha = 1;
    }];
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^() {
        self.dismissButton.alpha = 1;
    } completion:nil];
}


- (void)dismissButtonPressed:(UIButton *)button {
    if ([self.superview isKindOfClass:[HRPGExplanationView class]]) {
        [(HRPGExplanationView *)self.superview dismissAnimated:YES wasSeen:YES];
    }
}

- (void)remindAgainButtonPressed:(UIButton *)button {
    if ([self.superview isKindOfClass:[HRPGExplanationView class]]) {
        [(HRPGExplanationView *)self.superview dismissAnimated:YES wasSeen:NO];
    }}

@end
