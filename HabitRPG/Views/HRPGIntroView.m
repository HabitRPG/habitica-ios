//
//  HRPGIntroView.m
//  Habitica
//
//  Created by Phillip Thelen on 11/11/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGIntroView.h"
#import "EAIntroView.h"

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
        page1.titleFont = [UIFont boldSystemFontOfSize:18.0];
        page1.desc = NSLocalizedString(@"Join over 900,000 people having fun while getting things done. Create an avatar and track your real-life tasks.", nil);
        page1.descPositionY = titleposition - 24;
        
        EAIntroPage *page2 = [EAIntroPage page];
        page2.title = @"Game Progress = Life Progress";
        page2.titlePositionY = titleposition;
        page2.titleFont = [UIFont boldSystemFontOfSize:18.0];
        page2.desc = NSLocalizedString(@"Unlock features in the game by checking off your real-life tasks. Earn armor, pets, and more to reward you for meeting your goals!", nil);
        page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IntroPage2"]];
        CGFloat screenshotWidth = frame.size.width - 40;
        if (screenshotWidth > 322.5) {
            screenshotWidth = 322.5;
        }
        page2.titleIconView.contentMode = UIViewContentModeBottom;
        __weak EAIntroPage *weakPage = page2;
        page2.onPageDidLoad = ^() {
            weakPage.titleIconView.frame = CGRectMake((frame.size.width-screenshotWidth)/2, 0, screenshotWidth, 0);
        };
        page2.onPageDidDisappear = ^() {
            weakPage.titleIconView.frame = CGRectMake((frame.size.width-screenshotWidth)/2, 0, screenshotWidth, 0);
        };
        page2.onPageDidAppear = ^() {
            [UIView animateWithDuration:1.0 animations:^() {
                weakPage.titleIconView.frame = CGRectMake((frame.size.width-screenshotWidth)/2, 0, screenshotWidth, frame.size.height - titleposition - 20);
            }];
        };
        page2.descPositionY = titleposition - 24;

        EAIntroPage *page3 = [EAIntroPage page];
        page3.titlePositionY = titleposition;
        page3.titleFont = [UIFont boldSystemFontOfSize:18.0];
        page3.title = NSLocalizedString(@"Stay Social & Stay On Track", nil);
        page3.desc = NSLocalizedString(@"Fight monsters with your friends for social accountability. Stay on track together to reap the rewards!", nil);
        page3.descPositionY = titleposition - 24;

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
