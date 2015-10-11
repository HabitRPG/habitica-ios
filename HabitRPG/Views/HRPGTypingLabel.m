//
//  HRPGTypingLabel.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGTypingLabel.h"

@interface HRPGTypingLabel ()

@property NSInteger index;
@property NSString *setText;

@end

@implementation HRPGTypingLabel

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.typingSpeed = 0.03;
        self.editable = NO;
        self.userInteractionEnabled = NO;
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.backgroundColor = [UIColor clearColor];
        self.contentInset = UIEdgeInsetsMake(0,0,0,0);
    }
    
    return self;
}

- (void)setText:(NSString *)text {
    self.setText = text;
    self.index = 0;
    [NSTimer scheduledTimerWithTimeInterval:self.typingSpeed
                                     target:self
                                   selector:@selector(updateText:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) updateText:(NSTimer *)timer {
    self.index++;
    if (self.index > self.setText.length) {
        [timer invalidate];
        timer = nil;
        if (self.finishedAction) {
            self.finishedAction();
        }
    } else {
        super.text = [self.setText substringToIndex:self.index];
    }
}

@end
