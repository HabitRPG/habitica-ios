//
//  HRPGPurchaseLoadingButton.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGPurchaseLoadingButton.h"
#import "Habitica-Swift.h"

@interface HRPGPurchaseLoadingButton ()

@property UILabel *label;
@property UIActivityIndicatorView *loadingView;
@property UIColor *originalTintColor;
@end

@implementation HRPGPurchaseLoadingButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.layer.cornerRadius = 8.0f;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.font = [UIFont systemFontOfSize:16];
        self.loadingView = [[UIActivityIndicatorView alloc] init];
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;

        self.tintColor = [ObjcThemeWrapper tintColor];
        self.layer.masksToBounds = YES;
        self.text = @"";
        self.confirmText = objcL10n.buy;
        self.doneText = objcL10n.success;
        self.state = HRPGPurchaseButtonStateLabel;
        UILongPressGestureRecognizer *tapGestureRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGestureRecognizer.minimumPressDuration = 0.001;
        [self addGestureRecognizer:tapGestureRecognizer];
        self.userInteractionEnabled = YES;
    }

    return self;
}

- (void)layoutSubviews {
    self.label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.loadingView.frame = CGRectMake((self.frame.size.width - self.frame.size.height) / 2, 0,
                                        self.frame.size.height, self.frame.size.height);
}

- (void)setText:(NSString *)text {
    _text = text;
    if (self.state == HRPGPurchaseButtonStateLabel) {
        self.label.text = self.text;
        self.label.textColor = [UIColor whiteColor];
    }
}

- (void)setConfirmText:(NSString *)text {
    _confirmText = text;
    if (self.state == HRPGPurchaseButtonStateConfirm) {
        self.label.text = self.confirmText;
    }
}

- (void)setDoneText:(NSString *)text {
    _doneText = text;
    if (self.state == HRPGPurchaseButtonStateDone) {
        self.label.text = self.doneText;
    }
}

- (void)setState:(HRPGPurchaseButtonState)state {
    if (_state == HRPGPurchaseButtonStateError && _state != state) {
        self.tintColor = self.originalTintColor;
    }
    _state = state;

    switch (state) {
        case HRPGPurchaseButtonStateLabel:
            [self removeLoadingIndicatorFromView];
            [self addLabelToView];
            self.label.text = self.text;
            break;
        case HRPGPurchaseButtonStateConfirm:
            [self removeLoadingIndicatorFromView];
            [self addLabelToView];
            self.label.text = [self.confirmText uppercaseString];
            break;
        case HRPGPurchaseButtonStateLoading:
            [self addLoadingIndicatorToView];
            self.label.text = @"";
            break;
        case HRPGPurchaseButtonStateDone:
            [self removeLoadingIndicatorFromView];
            [self addLabelToView];
            self.label.text = [self.doneText uppercaseString];
            break;
        case HRPGPurchaseButtonStateError:
            [self removeLoadingIndicatorFromView];
            [self addLabelToView];
            self.originalTintColor = self.tintColor;
            self.tintColor = [ObjcThemeWrapper errorColor];
            self.label.text = [objcL10n.error localizedUppercaseString];
            break;

        default:
            break;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.label.layer.backgroundColor = [tintColor CGColor];
}

- (void)addLabelToView {
    if (![self.label isDescendantOfView:self]) {
        [self addSubview:self.label];
    }
}

- (void)removeLabelFromView {
    [self.label removeFromSuperview];
}

- (void)addLoadingIndicatorToView {
    if (![self.loadingView isDescendantOfView:self]) {
        [self addSubview:self.loadingView];
        [self.loadingView startAnimating];
    }
}

- (void)removeLoadingIndicatorFromView {
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
}

- (void)highlightButton {
    [UIView animateWithDuration:0.2
                     animations:^() {
                         self.layer.backgroundColor = [self.tintColor CGColor];
                         self.label.textColor = [UIColor whiteColor];
                     }];
}

- (void)dehighlightButton {
    [UIView animateWithDuration:0.2
                     animations:^() {
                         self.layer.backgroundColor = [[UIColor clearColor] CGColor];
                         self.label.textColor = [UIColor whiteColor];
                     }];
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    switch (tapGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self highlightButton];
            break;
        case UIGestureRecognizerStateEnded:
            if (self.onTouchEvent) {
                self.onTouchEvent(self);
            }
        default:
            [self dehighlightButton];
            break;
    }
}

@end
