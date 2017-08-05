//
//  Reward.m
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Reward.h"
#import "HRPGManager.h"

@implementation Reward

@dynamic dateCreated;
@dynamic user;
@dynamic tags;
@dynamic tagArray;

- (void)willSave {
    if (![self.rewardType isEqualToString:@"reward"]) {
        self.rewardType = @"reward";
    }
}

- (NSArray *)getTagArray {
    NSMutableArray *tagArray = [NSMutableArray array];
    for (Tag *tag in self.tags) {
        [tagArray addObject:tag.id];
    }
    return tagArray;
}

- (void)setTagArray:(NSArray *)tagArray {
    if (tagArray.count == 0) {
        return;
    }
    NSManagedObjectContext *managedObjectContext =
        [HRPGManager sharedManager].getManagedObjectContext;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    for (Tag *tag in tags) {
        if ([tagArray containsObject:tag.id]) {
            if (![self.tags containsObject:tag]) {
                [self addTagsObject:tag];
            }
        } else {
            if ([self.tags containsObject:tag]) {
                [self removeTagsObject:tag];
            }
        }
    }
}

@end
