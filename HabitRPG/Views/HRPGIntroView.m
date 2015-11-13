//
//  HRPGIntroView.m
//  Habitica
//
//  Created by Phillip Thelen on 11/11/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGIntroView.h"
#import "EAIntroView.h"
#import "UIColor+Habitica.h"

@interface HRPGIntroView ()

@property EAIntroView* intro;

@end

@implementation HRPGIntroView

- (HRPGIntroView *)initWithFrame:(CGRect) frame {
    self = [super init];
    
    if (self) {
        
        CGFloat titleposition = (frame.size.height / 2) - (frame.size.height / 16);
        
        EAIntroPage *page1 = [EAIntroPage page];
        page1.title = NSLocalizedString(@"Welcome to Habitica", nil);
        page1.titlePositionY = titleposition;
        page1.titleFont = [UIFont boldSystemFontOfSize:20.0];
        page1.desc = NSLocalizedString(@"Join over 900,000 people having fun while getting things done. Create an avatar and track your real-life tasks.", nil);
        page1.descPositionY = titleposition - 24;
        page1.descFont = [UIFont systemFontOfSize:14.0];
        page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IntroPage1"]];
        page1.titleIconPositionY = titleposition - 90;
        
        __weak EAIntroPage *weakPage1 = page1;
        page1.onPageDidLoad = ^() {
            weakPage1.titleIconView.alpha = 0;
        };
        page1.onPageDidDisappear = ^() {
            weakPage1.titleIconView.alpha = 0;
        };
        page1.onPageDidAppear = ^() {
            [UIView animateWithDuration:0.8 animations:^() {
                weakPage1.titleIconView.alpha = 1;
            }];
        };
        
        EAIntroPage *page2 = [EAIntroPage page];
        page2.title = @"Game Progress = Life Progress";
        page2.titlePositionY = titleposition;
        page2.titleFont = [UIFont boldSystemFontOfSize:20.0];
        page2.desc = NSLocalizedString(@"Unlock features in the game by checking off your real-life tasks. Earn armor, pets, and more to reward you for meeting your goals!", nil);
        page2.descPositionY = titleposition - 24;
        page2.descFont = [UIFont systemFontOfSize:14.0];
        page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IntroPage2"]];
        page2.titleIconPositionY = titleposition - 220;
        __weak EAIntroPage *weakPage2 = page2;
        page2.onPageDidLoad = ^() {
            weakPage2.titleIconView.alpha = 0;
        };
        page2.onPageDidDisappear = ^() {
            weakPage2.titleIconView.alpha = 0;
        };
        page2.onPageDidAppear = ^() {
            [UIView animateWithDuration:0.8 animations:^() {
                weakPage2.titleIconView.alpha = 1;
            }];
        };

        EAIntroPage *page3 = [EAIntroPage page];
        page3.titlePositionY = titleposition;
        page3.titleFont = [UIFont boldSystemFontOfSize:20.0];
        page3.title = NSLocalizedString(@"Get Social and Fight Monsters", nil);
        page3.desc = NSLocalizedString(@"Stay on track with your goals by staying accountable. Support your friends by battling monsters together, and reap the real-life rewards.", nil);
        page3.descPositionY = titleposition - 24;
        page3.descFont = [UIFont systemFontOfSize:14.0];
        page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IntroPage3"]];
        page3.titleIconPositionY = titleposition - 230;

        __weak EAIntroPage *weakPage3 = page3;
        page3.onPageDidLoad = ^() {
            weakPage3.titleIconView.alpha = 0;
        };
        page3.onPageDidDisappear = ^() {
            weakPage3.titleIconView.alpha = 0;
        };
        page3.onPageDidAppear = ^() {
            [UIView animateWithDuration:0.8 animations:^() {
                weakPage3.titleIconView.alpha = 1;
            }];
        };
        
        self.intro = [[EAIntroView alloc] initWithFrame:frame andPages:@[page1, page2, page3]];
        self.intro.bgImage = [UIImage imageNamed:@"IntroBackground"];
    }
    
    return self;
}

- (void)displayInView:(UIView *)view {
    [self.intro showInView:view animateDuration:0.0];
}

- (void) setDelegate:(id<EAIntroDelegate>) delegate {
    self.intro.delegate = delegate;
}



@end
