//
//  HRPGPurchaseLoadingButton.m
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGPurchaseLoadingButton.h"

@interface HRPGPurchaseLoadingButton ()

@property UILabel *label;
@property UIActivityIndicatorView *loadingView;

@end

@implementation HRPGPurchaseLoadingButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.layer.borderWidth = 1.0f;
        self.label.layer.cornerRadius = 5.0f;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.loadingView = [[UIActivityIndicatorView alloc] init];
        self.loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        self.tintColor = [UIColor blueColor];
        self.text = @"";
        self.confirmText = @"buy";
        self.doneText = @"done";
        self.state = HRPGPurchaseButtonStateLabel;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    self.label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.loadingView.frame = CGRectMake((self.frame.size.width-self.frame.size.height)/2, 0, self.frame.size.height, self.frame.size.height);
}

- (void)setText:(NSString *)text {
    _text = text;
    if (self.state == HRPGPurchaseButtonStateLabel) {
        self.label.text = self.text;
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
    _state = state;
    if (state == HRPGPurchaseButtonStateLabel) {
        self.label.text = self.text;
    }
    
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
            
        default:
            break;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.label.textColor = tintColor;
    self.label.layer.borderColor = [tintColor CGColor];
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

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.onTouchEvent) {
        self.onTouchEvent(self);
    }
}

@end
