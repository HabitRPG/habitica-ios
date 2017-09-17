//
//  Task+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 17/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Task+CoreDataClass.h"
#import "Reminder.h"
#import "Tag.h"
#import "User.h"
#import "UIColor+Habitica.h"
#import "NSDate+DaysSince.h"
#import "NSString+Emoji.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "HRPGManager.h"

@interface OldTask ()

@property BOOL observesCompleted;

@end

@implementation OldTask

@synthesize currentlyChecking;
@synthesize observesCompleted;

+ (NSArray *)predicatesForTaskType:(NSString *)taskType withFilterType:(NSInteger)filterType withOffset:(NSInteger)offset {
    if ([taskType isEqual:@"habit"]) {
        switch (filterType) {
            case TaskHabitFilterTypeAll: {
                return @[ [NSPredicate predicateWithFormat:@"type=='habit'"] ];
            }
            case TaskHabitFilterTypeWeak: {
                return @[ [NSPredicate predicateWithFormat:@"type=='habit' && value <= 0"] ];
            }
            case TaskHabitFilterTypeStrong: {
                return @[ [NSPredicate predicateWithFormat:@"type=='habit' && value > 0"] ];
            }
        }
    } else if ([taskType isEqual:@"daily"]) {
        switch (filterType) {
            case TaskDailyFilterTypeAll: {
                return @[ [NSPredicate predicateWithFormat:@"type=='daily'"] ];
            }
            case TaskDailyFilterTypeDue: {
                NSArray *predicates =
                @[ [NSPredicate predicateWithFormat:@"type=='daily' && completed==NO && isDue==YES"] ];
                return predicates;
            }
            case TaskDailyFilterTypeGrey: {
                NSArray *predicates = @[ [NSPredicate predicateWithFormat:@"type=='daily' && completed==YES || isDue==NO"] ];
                return predicates;
            }
        }
    } else if ([taskType isEqual:@"todo"]) {
        switch (filterType) {
            case TaskToDoFilterTypeActive: {
                return @[ [NSPredicate predicateWithFormat:@"type=='todo' && completed==NO"] ];
            }
            case TaskToDoFilterTypeDated: {
                return @[ [NSPredicate
                           predicateWithFormat:@"type=='todo' && completed==NO && duedate!=nil"] ];
            }
            case TaskToDoFilterTypeDone: {
                return @[ [NSPredicate predicateWithFormat:@"type=='todo' && completed==YES"] ];
            }
        }
    }
    return @[];
}

@end
