//
//  HRPGPetHatchedOverlayView.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGImageOverlayView.h"
#import <pop/POP.h>

@interface HRPGImageOverlayView ()
@property UIView *indicatorView;
@property UILabel *label;
@property UILabel *detailLabel;
@property UIView *animationView;
@end


@implementation HRPGImageOverlayView

- (id)init {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    _height = 140;
    _width = 160;
    
    CGRect frame = CGRectMake((screenSize.width - self.width) / 2, -self.height, self.width, self.height);
    self = [super init];
    if (self) {
        self.indicatorView = [[UIView alloc] initWithFrame:frame];
        self.indicatorView.backgroundColor = [UIColor whiteColor];
        self.indicatorView.alpha = 0;
        [self.indicatorView.layer setCornerRadius:5.0f];
        
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0];
        
        self.ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, self.width-20, self.height-50)];
        self.ImageView.contentMode = UIViewContentModeCenter;
        [self.indicatorView addSubview:self.ImageView];
        
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        [self.indicatorView addSubview:self.label];
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        self.detailLabel.numberOfLines = 0;
        [self.indicatorView addSubview:self.detailLabel];
        
        UITabBarController *mainTabbar = ((UITabBarController *) [[UIApplication sharedApplication] delegate].window.rootViewController);
        [mainTabbar.view addSubview:self.indicatorView];

        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.indicatorView addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, (screenSize.height - self.height) / 2, self.width, self.height);
    if (!self.descriptionText && !self.detailText) {
        self.ImageView.frame = CGRectMake(10, 20, self.width-20, self.height-50);
    }
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, (screenSize.height - self.height) / 2, self.width, self.height);
    self.ImageView.frame = CGRectMake(10, 20, self.width-20, self.height-50);
}

- (void)display:(void (^)())completitionBlock {
    POPSpringAnimation *sizeAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sizeAnim.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.7, 0.7)];
    sizeAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
    sizeAnim.springBounciness=11;
    sizeAnim.springSpeed=3;
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.fromValue = @(0.0);
    alphaAnim.toValue = @(1.0);
    alphaAnim.duration = 0.4;
    
    POPBasicAnimation *moveAnim = [POPBasicAnimation easeInAnimation];
    moveAnim.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
    moveAnim.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.indicatorView.frame.origin.x+(self.indicatorView.frame.size.width/2), self.indicatorView.frame.origin.y+(self.indicatorView.frame.size.height/2)+25)];
    moveAnim.duration = 0.4;
    
    [self.indicatorView pop_addAnimation:sizeAnim forKey:@"sizeAnimation"];
    [self.indicatorView pop_addAnimation:alphaAnim forKey:@"alphaAnimation"];
    [self.indicatorView pop_addAnimation:moveAnim forKey:@"moveAnimation"];
}

- (void)dismiss:(void (^)())completitionBlock {
    POPSpringAnimation *sizeAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sizeAnim.toValue = [NSValue valueWithCGSize:CGSizeMake(0.7, 0.7)];
    sizeAnim.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
    sizeAnim.springBounciness=14;
    sizeAnim.springSpeed=2.5;
    
    POPBasicAnimation *alphaAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnim.fromValue = @(1.0);
    alphaAnim.toValue = @(0.0);
    alphaAnim.duration = 0.2;
    alphaAnim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [self.indicatorView removeFromSuperview];
        completitionBlock();
        self.dismissBlock();
    };

    [self.indicatorView pop_addAnimation:sizeAnim forKey:@"sizeAnimation"];
    [self.indicatorView pop_addAnimation:alphaAnim forKey:@"alphaAnimation"];
}

- (void)setDescriptionText:(NSString *)descriptionText {
    _descriptionText = descriptionText;
    self.label.text = descriptionText;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSInteger height = [descriptionText boundingRectWithSize:CGSizeMake(self.width-20, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                         NSFontAttributeName : self.label.font
                                                         }
                                                 context:nil].size.height+5;
    self.height = self.height + height;
    self.label.frame = CGRectMake(10, self.height-height-10, self.width-20, height);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, (screenSize.height - self.height) / 2, self.width, self.height);
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    self.detailLabel.text = detailText;
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    NSInteger height = [detailText boundingRectWithSize:CGSizeMake(self.width-20, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                               NSFontAttributeName : self.detailLabel.font
                                                               }
                                                     context:nil].size.height+5;
    self.height = self.height + height;
    self.detailLabel.frame = CGRectMake(10, self.height-height-10, self.width-20, height);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.indicatorView.frame = CGRectMake((screenSize.width - self.width) / 2, (screenSize.height - self.height) / 2, self.width, self.height);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self dismiss:^() {
    }];
}

- (void)displayImageWithName:(NSString *)imageName {
    [self.ImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pherth.net/habitrpg/%@", imageName]] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
}
@end
