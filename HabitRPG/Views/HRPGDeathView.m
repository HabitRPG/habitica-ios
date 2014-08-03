//
//  HRPGDeathView.m
//  RabbitRPG
//
//  Created by Phillip on 02/08/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDeathView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@interface HRPGDeathView ()
@property (weak) HRPGManager *sharedManager;
@property UILabel *diedLabel;
@property UIImageView *deathImageView;
@property UILabel *deathText;
@property UILabel *tapLabel;
@end

@implementation HRPGDeathView

- (id)init {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        [self addGestureRecognizer:singleFingerTap];
        UIWindow* mainWindow = [[UIApplication sharedApplication] keyWindow];
        [mainWindow addSubview: self];
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
        
        self.diedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screenRect.size.height/2-150, screenRect.size.width, 30)];
        self.diedLabel.font = [UIFont boldSystemFontOfSize:25];
        self.diedLabel.text = NSLocalizedString(@"You Died", nil);
        self.diedLabel.alpha = 0;
        self.diedLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.diedLabel];
        
        self.deathImageView = [[UIImageView alloc] initWithFrame:CGRectMake(screenRect.size.width/2-57, screenRect.size.height/2-96, 114, 132)];
        [self.deathImageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/GrimReaper.png"]
                       placeholderImage:[UIImage imageNamed:@"Placeholder"]];
        self.deathImageView.alpha = 0;
        [self addSubview:self.deathImageView];
        
        self.deathText = [[UILabel alloc] initWithFrame:CGRectMake(10, screenRect.size.height/2+50, screenRect.size.width-20, 120)];
        self.deathText.font = [UIFont systemFontOfSize:14];
        self.deathText.text = NSLocalizedString(@"You've lost a Level, all your Gold, and a random piece of Equipment. Arise, Habiteer, and try again! Curb those negative Habits, be vigilant in completion of Dailies, and hold death at arm's length with a Health Potion if you falter!", nil);
        self.deathText.alpha = 0;
        self.deathText.numberOfLines = 0;
        self.deathText.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.deathText];
        
        self.tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, screenRect.size.height-60, screenRect.size.width, 30)];
        self.tapLabel.font = [UIFont boldSystemFontOfSize:14];
        self.tapLabel.text = NSLocalizedString(@"Tap to continue", nil);
        self.tapLabel.alpha = 0;
        self.tapLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.tapLabel];
    }
    return self;
}

- (void)show {
    [UIView animateWithDuration:1.0f animations:^() {
        self.backgroundColor = [UIColor whiteColor];
    }completion:^(BOOL competed) {
        [UIView animateWithDuration:1.0f animations:^() {
            self.deathImageView.alpha = 1;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.0f animations:^() {
                self.deathText.alpha = 1;
                self.diedLabel.alpha = 1;
                self.tapLabel.alpha = 1;
            }];
        });
        
    }];
}

- (void)show:(void (^)())onHide {
    
}

-(void) dismiss:(UITapGestureRecognizer *)recognizer {
    [self dismiss];
}

-(void) dismiss {
    [UIView animateWithDuration:0.8f animations:^() {
        self.alpha = 0;
    } completion:^(BOOL completed) {
        [self removeFromSuperview];
    }];
    
    [_sharedManager reviveUser:^(){
    } onError:^(){
    }];
}

@end
