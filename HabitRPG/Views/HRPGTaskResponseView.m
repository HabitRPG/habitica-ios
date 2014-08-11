//
//  HRPGTaskResponseView.m
//  RabbitRPG
//
//  Created by Phillip on 03/08/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTaskResponseView.h"

@interface HRPGTaskResponseView()
@property UILabel *ExpLabel;
@property UIProgressView *ExpProgress;
@property UIImageView *goldImageView;
@property UILabel *goldLabel;
@property UIImageView *silverImageView;
@property UILabel *silverLabel;
@property UIView *moneyView;
@property UILabel *healthLabel;
@property UIProgressView *healthProgress;
@property NSMutableArray *queue;
@property NSDate *lastUpdate;
@property BOOL shouldDismiss;
@property float delay;
@end

@implementation HRPGTaskResponseView

- (id)init {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, 60)];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.973 alpha:0.950];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissByTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
        // Add a bottomBorder.
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-1, self.frame.size.width, 0.5f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.678 alpha:1.000].CGColor;
        [self.layer addSublayer:bottomBorder];
        
        self.queue = [NSMutableArray array];
        self.isVisible = NO;
        self.isDisplaying = NO;
    }
    return self;
}

- (void)addHealthView {
    if (self.healthLabel) {
        return;
    }
    self.healthLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width, 30)];
    self.healthLabel.font = [UIFont systemFontOfSize:15];
    self.healthLabel.textColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
    self.healthLabel.text = [NSString stringWithFormat:@"Health: %@/%@", self.health, self.healthMax];
    [self.healthLabel sizeToFit];
    self.healthLabel.alpha = 0;
    [self addSubview:self.healthLabel];
    
    self.healthProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(self.healthLabel.frame.size.width + 16, 15, self.frame.size.width - (self.healthLabel.frame.size.width + 24), 2)];
    self.healthProgress.progressTintColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
    self.healthProgress.progress = [self.health floatValue] / [self.healthMax floatValue];
    self.healthProgress.alpha = 0;
    [self addSubview:self.healthProgress];
    
    if (self.ExpLabel) {
        [UIView animateWithDuration:0.2 animations:^() {
            self.ExpLabel.alpha = 0;
            self.ExpProgress.alpha = 0;
            self.moneyView.alpha = 0;
        } completion:^(BOOL completed) {
            [self.ExpProgress removeFromSuperview];
            [self.ExpLabel removeFromSuperview];
            [self.moneyView removeFromSuperview];
            self.ExpLabel = nil;
            self.ExpProgress = nil;
            self.moneyView = nil;
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^() {
        self.healthLabel.alpha = 1;
        self.healthProgress.alpha = 1;
    }];
}

- (void) addExpAndGoldViews {
    if (self.ExpLabel) {
        return;
    }
    self.ExpLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.frame.size.width, 30)];
    self.ExpLabel.font = [UIFont systemFontOfSize:15];
    self.ExpLabel.textColor = [UIColor colorWithRed:0.870 green:0.686 blue:0.037 alpha:1.000];
    self.ExpLabel.text = [NSString stringWithFormat:@"Exp: %@/%@", self.experience, self.experienceMax];
    [self.ExpLabel sizeToFit];
    self.ExpLabel.alpha = 0;
    [self addSubview:self.ExpLabel];

    self.ExpProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(self.ExpLabel.frame.size.width + 16, 15, self.frame.size.width - (self.ExpLabel.frame.size.width + 24), 2)];
    self.ExpProgress.progressTintColor = [UIColor colorWithRed:0.870 green:0.686 blue:0.037 alpha:1.000];
    self.ExpProgress.progress = [self.experience floatValue] / [self.experienceMax floatValue];
    self.ExpProgress.alpha = 0;
    [self addSubview:self.ExpProgress];

    self.goldImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 22)];
    self.goldImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.goldImageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_gold.png"]];
    self.goldLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 2, 100, 20)];
    self.goldLabel.font = [UIFont systemFontOfSize:13.0f];
    self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [self.gold integerValue]];
    [self.goldLabel sizeToFit];
    
    
    self.silverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + self.goldLabel.frame.size.width, 0, 25, 22)];
    self.silverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.silverImageView setImageWithURL:[NSURL URLWithString:@"http://pherth.net/habitrpg/shop_silver.png"]];
    self.silverLabel = [[UILabel alloc] initWithFrame:CGRectMake(30 + self.goldLabel.frame.size.width + 26, 2, 100, 20)];
    self.silverLabel.font = [UIFont systemFontOfSize:13.0f];
    int silver = ([self.gold floatValue] - [self.gold integerValue]) * 100;
    self.silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    [self.silverLabel sizeToFit];
    
    
    int moneyWidth = self.goldImageView.frame.size.width + self.goldLabel.frame.size.width + self.silverImageView.frame.size.width + self.silverLabel.frame.size.width + 7;
    
    self.moneyView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width/2) - (moneyWidth / 2), 30, moneyWidth, 40)];
    self.moneyView.alpha = 0;
    [self.moneyView addSubview:self.goldLabel];
    [self.moneyView addSubview:self.goldImageView];
    [self.moneyView addSubview:self.silverImageView];
    [self.moneyView addSubview:self.silverLabel];
    [self addSubview:self.moneyView];

    if (self.healthLabel) {
        [UIView animateWithDuration:0.2 animations:^() {
            self.healthLabel.alpha = 0;
            self.healthProgress.alpha = 0;
        } completion:^(BOOL completed) {
            [self.healthProgress removeFromSuperview];
            [self.healthLabel removeFromSuperview];
            self.healthLabel = nil;
            self.healthProgress = nil;
        }];
    }
    
    [UIView animateWithDuration:0.2 animations:^() {
        self.moneyView.alpha = 1;
        self.ExpLabel.alpha = 1;
        self.ExpProgress.alpha = 1;
    }];
}

- (void) updateHealth:(NSNumber*)healthDiff withHealth:(NSNumber*)newHealth{
    if (!self.healthLabel) {
        [self addHealthView];
    }
    self.health = newHealth;
    
    self.healthLabel.text = [NSString stringWithFormat:@"Health: %@/%@", self.health, self.healthMax];
    [self.healthLabel sizeToFit];
    
    self.healthProgress.frame = CGRectMake(self.healthLabel.frame.size.width + 16, 15, self.frame.size.width - (self.healthLabel.frame.size.width + 24), 2);
    
    UILabel *updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - self.healthLabel.frame.size.width/2, self.healthLabel.frame.origin.y, self.healthLabel.frame.size.width, 16)];
    updateLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    updateLabel.textAlignment = NSTextAlignmentCenter;
    updateLabel.text = [NSString stringWithFormat:@"%.2f", [healthDiff floatValue]];
    updateLabel.textColor = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
    updateLabel.transform = CGAffineTransformScale(updateLabel.transform, 0.35, 0.35);
    [self addSubview:updateLabel];
    
    [UIView animateWithDuration:0.8 animations:^() {
        updateLabel.transform = CGAffineTransformScale(updateLabel.transform, 6, 6);
        self.healthProgress.progress = ([self.health floatValue] / [self.healthMax floatValue]);
    }                completion:^(BOOL completition) {
        [updateLabel removeFromSuperview];
        self.lastUpdate = [NSDate date];
        if (self.queue.count == 0) {
            self.isDisplaying = NO;
            if (self.shouldDismiss) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if (!self.isDisplaying && self.queue.count == 0 && [self.lastUpdate timeIntervalSinceNow] <= -self.delay) {
                        [self dismiss:nil];
                    }
                });
            }
            return;
        }
        NSArray *valuesArray = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        NSNumber *healthDiff = valuesArray[0];
        NSNumber *health = valuesArray[3];
        if ([health floatValue] != [self.health floatValue]) {
            [self updateHealth:healthDiff withHealth:health];
        } else {
            [self updateExp:valuesArray[1] withExperience:valuesArray[4] withGold:valuesArray[2]];
        }
    }];
    
    [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveEaseIn animations:^() {
        updateLabel.alpha = 0.0f;
    }completion:^(BOOL completed) {
        
    }];
    
    [self shakeHealthViews];
}

- (void) updateExp:(NSNumber*)expDiff withExperience:(NSNumber*)newExperience withGold:(NSNumber*)newGold {
    if (!self.ExpLabel) {
        [self addExpAndGoldViews];
    }
    self.experience = newExperience;
    self.ExpLabel.text = [NSString stringWithFormat:@"Exp: %@/%@", self.experience, self.experienceMax];
    [self.ExpLabel sizeToFit];
    
    self.ExpProgress.frame = CGRectMake(self.ExpLabel.frame.size.width + 16, 15, self.frame.size.width - (self.ExpLabel.frame.size.width + 24), 2);
    
    NSNumber *goldDiff = [NSNumber numberWithFloat:([newGold floatValue] - [self.gold floatValue])];
    self.gold = newGold;
    self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long) [self.gold integerValue]];
    [self.goldLabel sizeToFit];
    
    int silver = ([self.gold floatValue] - [self.gold integerValue]) * 100;
    self.silverLabel.text = [NSString stringWithFormat:@"%d", silver];
    self.silverLabel.frame = CGRectMake(30 + self.goldLabel.frame.size.width + 26, 2, 100, 16);
    
    [self.silverLabel sizeToFit];
    self.silverImageView.frame = CGRectMake(30 + self.goldLabel.frame.size.width, 0, 25, 22);
    
    int moneyWidth = self.goldImageView.frame.size.width + self.goldLabel.frame.size.width + self.silverImageView.frame.size.width + self.silverLabel.frame.size.width + 7;
    
    self.moneyView.frame = CGRectMake((self.frame.size.width/2) - (moneyWidth / 2), 30, moneyWidth, 40);
 
    UILabel *updateExpLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - self.ExpLabel.frame.size.width/2, self.ExpLabel.frame.origin.y, self.ExpLabel.frame.size.width, 16)];
    updateExpLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    updateExpLabel.textAlignment = NSTextAlignmentCenter;
    if ([expDiff intValue] < 0) {
        updateExpLabel.text = [NSString stringWithFormat:@"+%@", expDiff];
    } else {
        updateExpLabel.text = [NSString stringWithFormat:@"%@", expDiff];
    }
    updateExpLabel.textColor = [UIColor colorWithRed:0.870 green:0.686 blue:0.037 alpha:1.000];
    updateExpLabel.transform = CGAffineTransformScale(updateExpLabel.transform, 0.35, 0.35);
    [self addSubview:updateExpLabel];
    
    UILabel *updateGoldLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.goldLabel.frame.origin.x-10, self.goldLabel.frame.origin.y, self.goldLabel.frame.size.width+20, 16)];
    updateGoldLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    updateGoldLabel.textAlignment = NSTextAlignmentCenter;
    if ([goldDiff intValue] > 0) {
        updateGoldLabel.text = [NSString stringWithFormat:@"+%d", [goldDiff intValue]];
    } else {
        updateGoldLabel.text = [NSString stringWithFormat:@"%d", [goldDiff intValue]];
    }
    updateGoldLabel.textColor = [UIColor colorWithRed:0.292 green:0.642 blue:0.013 alpha:1.000];
    updateGoldLabel.transform = CGAffineTransformScale(updateGoldLabel.transform, 0.35, 0.35);
    [self.moneyView addSubview:updateGoldLabel];
    
    UILabel *updateSilverLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.silverLabel.frame.origin.x-10, self.silverLabel.frame.origin.y, self.silverLabel.frame.size.width+20, 16)];
    updateSilverLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    updateSilverLabel.textAlignment = NSTextAlignmentCenter;
    int silverDiff = ([goldDiff floatValue] - [goldDiff integerValue]) * 100;
    updateSilverLabel.text = [NSString stringWithFormat:@"+%d", silverDiff];
    updateSilverLabel.textColor = [UIColor colorWithRed:0.292 green:0.642 blue:0.013 alpha:1.000];
    updateSilverLabel.transform = CGAffineTransformScale(updateSilverLabel.transform, 0.35, 0.35);
    [self.moneyView addSubview:updateSilverLabel];
    
    [UIView animateWithDuration:0.8 animations:^() {
        updateGoldLabel.transform = CGAffineTransformScale(updateGoldLabel.transform, 6, 6);
        updateSilverLabel.transform = CGAffineTransformScale(updateSilverLabel.transform, 6, 6);
        updateExpLabel.transform = CGAffineTransformScale(updateExpLabel.transform, 6, 6);
        self.ExpProgress.progress = [self.experience floatValue] / [self.experienceMax floatValue];
    }                completion:^(BOOL completition) {
        [updateGoldLabel removeFromSuperview];
        [updateSilverLabel removeFromSuperview];
        [updateExpLabel removeFromSuperview];
        self.lastUpdate = [NSDate date];
        if (self.queue.count == 0) {
            self.isDisplaying = NO;
            if (self.shouldDismiss) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    if (!self.isDisplaying && self.queue.count == 0 && [self.lastUpdate timeIntervalSinceNow] <= -self.delay) {
                        [self dismiss:nil];
                    }
                });
            }
            return;
        }
        NSArray *valuesArray = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        NSNumber *healthDiff = valuesArray[0];
        NSNumber *health = valuesArray[3];
        if ([health floatValue] != [self.health floatValue]) {
            [self updateHealth:healthDiff withHealth:health];
        } else {
            [self updateExp:valuesArray[1] withExperience:valuesArray[4] withGold:valuesArray[2]];
        }
    }];
    
    [UIView animateWithDuration:0.2 delay:0.6 options:UIViewAnimationOptionCurveEaseIn animations:^() {
        updateExpLabel.alpha = 0.0f;
        updateSilverLabel.alpha = 0.0f;
        updateGoldLabel.alpha = 0.0f;
    }completion:^(BOOL completed) {
        
    }];
}

- (void) show {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^() {
        self.frame = CGRectMake(0, 64, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL completed) {
        self.isVisible = YES;
        if (!self.isDisplaying && self.queue.count != 0) {
            NSArray *valuesArray = [self.queue objectAtIndex:0];
            [self.queue removeObjectAtIndex:0];
            NSNumber *healthDiff = valuesArray[0];
            NSNumber *health = valuesArray[3];
            if ([health floatValue] != [self.health floatValue]) {
                [self updateHealth:healthDiff withHealth:health];
            } else {
                [self updateExp:valuesArray[1] withExperience:valuesArray[4] withGold:valuesArray[2]];
            }
        }
    }];
}

- (void) hide {
    [self hide:NO completed:nil];
}

- (void) hide:(BOOL)removeFromSuperView completed:(void (^)())completedBlock {
    self.isVisible = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^() {
        self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL completed) {
        if (removeFromSuperView) {
            [self removeFromSuperview];
        }
        if (completedBlock) {
            completedBlock();
        }
    }];
}

-(void) dismiss:(void (^)())completed {
    [self hide:YES completed:completed];
}

-(void)dismisswithDelay:(float)delay completed:(void (^)())completed {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.queue.count ==0 || [self.lastUpdate timeIntervalSinceNow] <= -delay+1) {
            [self hide:YES completed:completed];
        }
    });
}

- (void)shouldDismissWithDelay:(float)delay {
    self.delay = delay;
    self.shouldDismiss = YES;
}

-(void) dismissByTap:(UITapGestureRecognizer *)recognizer {
    [self hide:YES completed:nil];
}

-(void) updateWithValues:(NSArray*)valuesArray {
    if (self.isDisplaying || !self.isVisible) {
        [self.queue addObject:valuesArray];
    } else {
        self.isDisplaying = YES;
        NSNumber *healthDiff = valuesArray[0];
        NSNumber *health = valuesArray[3];
        self.experienceMax = valuesArray[5];
        if ([healthDiff floatValue] != 0) {
            [self updateHealth:healthDiff withHealth:health];
        } else {
            [self updateExp:valuesArray[1] withExperience:valuesArray[4] withGold:valuesArray[2]];
        }
    }
}

- (void) shakeHealthViews {
    CGAffineTransform firstTranslate  = CGAffineTransformTranslate(CGAffineTransformIdentity, ((float)rand() / RAND_MAX) * 7, ((float)rand() / RAND_MAX) * 7);
    CGAffineTransform secondTranslate  = CGAffineTransformTranslate(CGAffineTransformIdentity, ((float)rand() / RAND_MAX) * 7, ((float)rand() / RAND_MAX) * 7);
    CGAffineTransform thirdTranslate  = CGAffineTransformTranslate(CGAffineTransformIdentity, ((float)rand() / RAND_MAX) * 7, ((float)rand() / RAND_MAX) * 7);
    self.healthProgress.transform = firstTranslate;
    self.healthLabel.transform = firstTranslate;

    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        self.healthProgress.transform = secondTranslate;
        self.healthLabel.transform = secondTranslate;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
                [UIView setAnimationRepeatCount:2.0];
                self.healthProgress.transform = thirdTranslate;
                self.healthLabel.transform = thirdTranslate;
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                        self.healthProgress.transform = CGAffineTransformIdentity;
                        self.healthLabel.transform = CGAffineTransformIdentity;
                    } completion:NULL];
                }
            }];
        }
    }];
}

@end
