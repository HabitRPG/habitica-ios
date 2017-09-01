//
//  FAQ.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "FAQ.h"

@implementation FAQ

@dynamic question;
@dynamic iosAnswer;
@dynamic webAnswer;
@dynamic mobileAnswer;
@dynamic index;

- (NSString *)getRelevantAnswer {
    if (self.iosAnswer && self.iosAnswer.length > 0) {
        return self.iosAnswer;
    } else if (self.mobileAnswer && self.mobileAnswer.length > 0) {
        return self.mobileAnswer;
    } else {
        return self.webAnswer;
    }
}

@end
