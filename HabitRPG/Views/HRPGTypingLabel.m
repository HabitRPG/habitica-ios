//
//  HRPGTypingLabel.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGTypingLabel.h"
#import "Habitica-Swift.h"

@interface HRPGTypingLabel ()

@property NSInteger index;
@property NSMutableAttributedString *setText;

@end

@implementation HRPGTypingLabel

- (instancetype)init {
    self = [super init];

    if (self) {
        self.typingSpeed = 0.06;
        self.editable = NO;
        self.userInteractionEnabled = NO;
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.backgroundColor = [UIColor clearColor];
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    return self;
}

- (void)setText:(NSString *)text {
    [self setText:text startAnimating:YES];
}

- (void)setText:(NSString *)text startAnimating:(BOOL)startAnimating {
    UIColor *color = [UIColor clearColor];
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color,
                             NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline],
                             };
    self.setText = [[[NSAttributedString alloc] initWithString:text attributes:attrs] mutableCopy];
    super.attributedText = self.setText;
    if (startAnimating) {
        [self startAnimating];
    }
}

- (void)startAnimating {
    self.index = 0;
    [NSTimer scheduledTimerWithTimeInterval:self.typingSpeed
                                     target:self
                                   selector:@selector(updateText:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateText:(NSTimer *)timer {
    self.index++;
    if (self.index > self.setText.length) {
        [timer invalidate];
        timer = nil;
        if (self.finishedAction) {
            self.finishedAction();
        }
    } else {
        [self.setText addAttribute:NSForegroundColorAttributeName value:[ObjcThemeWrapper primaryTextColor] range:NSMakeRange(0,self.index )];
        super.attributedText = self.setText;
    }
}

@end
