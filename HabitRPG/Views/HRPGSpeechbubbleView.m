//
//  HRPGSpeechbubbleView.m
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGSpeechbubbleView.h"
#import "HRPGTypingLabel.h"

@interface HRPGSpeechbubbleView ()

@property HRPGTypingLabel *textLabel;
@property UIImageView *backgroundView;
@end

@implementation HRPGSpeechbubbleView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"speech_bubble"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 40, 28, 12)]];
        [self addSubview:self.backgroundView];
        self.textLabel = [[HRPGTypingLabel alloc] init];
        [self addSubview:self.textLabel];
        self.textColor = [UIColor blackColor];
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.textLabel.frame = CGRectMake(8, 0, frame.size.width-16, frame.size.height-16);
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.textLabel.textColor = textColor;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textLabel.text = text;
}

@end
