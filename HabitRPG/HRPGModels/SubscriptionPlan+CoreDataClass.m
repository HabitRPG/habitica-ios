//
//  SubscriptionPlan+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "SubscriptionPlan+CoreDataClass.h"
#import "User.h"
@implementation SubscriptionPlan

- (Boolean)isActive {
    return self.planId != nil && (self.dateTerminated != nil || [self.dateTerminated compare:[NSDate date]] != NSOrderedAscending);
}

- (NSInteger)totalGemCap {
    return 25 + self.gemCapExtra.intValue;
}

- (NSInteger)gemsLeft {
    return self.totalGemCap - [self.gemsBought integerValue];
}

- (void)setMysteryItemsArray:(NSArray *)mysteryItemsArray {
    self.mysteryItemCount = [NSNumber numberWithInteger:mysteryItemsArray.count];
}

- (NSArray *)mysteryItemsArray {
    return nil;
}

@end
