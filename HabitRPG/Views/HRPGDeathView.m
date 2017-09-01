//
//  HRPGDeathView.m
//  Habitica
//
//  Created by Phillip on 02/08/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGDeathView.h"
#import "YYWebImage.h"
#import "HRPGLabeledProgressBar.h"
#import "UIColor+Habitica.h"
#import "HRPGManager.h"
#import "Habitica-Swift.h"

@interface HRPGDeathView ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HRPGLabeledProgressBar *healthView;
@property (weak, nonatomic) IBOutlet UIView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *tryAgainLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property UITapGestureRecognizer *reviveGestureRecognizer;
@end

@implementation HRPGDeathView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.reviveGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self addGestureRecognizer:self.reviveGestureRecognizer];
        
        self.frame = [[UIScreen mainScreen] bounds];
        [self setNeedsLayout];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.healthView.color = [UIColor red100];
    self.healthView.icon = HabiticaIcons.imageOfHeartLightBg;
    self.healthView.type = NSLocalizedString(@"Health", nil);
    self.healthView.value = @0;
    self.healthView.maxValue = @50;
    
    User *user = [[HRPGManager sharedManager] getUser];
    [user setAvatarSubview:self.avatarView showsBackground:NO showsMount:NO showsPet:NO isFainted:YES];
}

- (void)show {
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:self];
    [UIView animateWithDuration:1.0f
        animations:^() {
            self.backgroundColor = [UIColor whiteColor];
        }
        completion:^(BOOL competed) {
            [UIView animateWithDuration:1.0f
                             animations:^() {
                                 self.containerView.alpha = 1;
                             }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC),
                           dispatch_get_main_queue(), ^{
                               [UIView animateWithDuration:1.0f
                                                animations:^() {
                                                    self.tryAgainLabel.alpha = 1;
                                                }];
                           });
        }];
}

- (void)dismiss:(UITapGestureRecognizer *)recognizer {
    [self revive];
}

- (void) revive {
    [self removeGestureRecognizer:self.reviveGestureRecognizer];
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         [self.loadingIndicator startAnimating];
                         self.loadingIndicator.alpha = 1;
                         self.tryAgainLabel.alpha = 0;
                     }];
    [[HRPGManager sharedManager] reviveUser:^() {
        [self dismiss];
    } onError:^(){
        [self dismiss];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.8f
        animations:^() {
            self.alpha = 0;
        }
        completion:^(BOOL completed) {
            [self removeFromSuperview];
        }];
}

@end
