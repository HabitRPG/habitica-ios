//
//  Task.m
//  HabitRPG
//
//  Created by Phillip Thelen on 23/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Task.h"
#import "ChecklistItem.h"
#import "Tag.h"
#import "HRPGAppDelegate.h"
#import "UIColor+Habitica.h"
#import "NSDate+DaysSince.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import "NSString+Emoji.h"
#import "Reminder.h"

@implementation Task

@dynamic attribute;
@dynamic completed;
@dynamic dateCreated;
@dynamic down;
@dynamic id;
@dynamic notes;
@dynamic order;
@dynamic priority;
@dynamic streak;
@dynamic text;
@dynamic type;
@dynamic up;
@dynamic value;
@dynamic monday;
@dynamic tuesday;
@dynamic wednesday;
@dynamic thursday;
@dynamic friday;
@dynamic saturday;
@dynamic sunday;
@dynamic checklist;
@dynamic tags;
@dynamic reminders;
@dynamic user;
@dynamic duedate;
@dynamic everyX;
@dynamic frequency;
@dynamic startDate;
@synthesize currentlyChecking;

- (BOOL)dueToday {
    return [self dueOnDate:[NSDate date] withOffset:0];
}

- (BOOL)dueTodayWithOffset:(NSInteger)offset {
    return [self dueOnDate:[NSDate date] withOffset:offset];
}

- (BOOL)dueOnDate:(NSDate *)date {
    return [self dueOnDate:date withOffset:0];
}

- (BOOL)dueOnDate:(NSDate *)date withOffset:(NSInteger)offset {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (self.startDate) {
        NSDate *startDateAtMidnight;
        [calendar rangeOfUnit:NSCalendarUnitDay
                    startDate:&startDateAtMidnight
                     interval:NULL
                      forDate:self.startDate];
        if ([self.startDate compare:[NSDate date]] == NSOrderedDescending) {
            return NO;
        }
    }
    // get today + the custom offset the user uses
    NSDate *dateWithOffset = [date dateByAddingTimeInterval:-(offset * 60 * 60)];
    if ([self.frequency isEqualToString:@"daily"]) {
        NSDate *startDate = [NSDate date];
        if (self.startDate) {
            startDate = self.startDate;
        }
        if ([self.everyX integerValue] == 0) {
            return true;
        }
        return ([[dateWithOffset daysSinceDate:startDate] integerValue] %
                [self.everyX integerValue]) == 0;
    } else {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        df.locale = locale;
        NSString *dateString = [df stringFromDate:dateWithOffset];
        return [[self valueForKey:[dateString lowercaseString]] boolValue];
    }
    return YES;
}

- (void)addChecklistObject:(ChecklistItem *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checklist];
    value.task = self;
    [tempSet addObject:value];
    self.checklist = tempSet;
}

- (void)removeChecklistObject:(ChecklistItem *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checklist];
    [tempSet removeObject:value];
    self.checklist = tempSet;
}

- (void)addRemindersObject:(Reminder *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.reminders];
    value.task = self;
    [tempSet addObject:value];
    self.reminders = tempSet;
}

- (void)removeRemindersObject:(Reminder *)value {
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.reminders];
    [tempSet removeObject:value];
    self.reminders = tempSet;
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
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext =
        appdelegate.sharedManager.getManagedObjectContext;

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

- (UIColor *)taskColor {
    NSInteger intValue = [self.value integerValue];
    if (intValue < -20) {
        return [UIColor darkRed50];
    } else if (intValue < -10) {
        return [UIColor red50];
    } else if (intValue < -1) {
        return [UIColor orange50];
    } else if (intValue < 1) {
        return [UIColor yellow50];
    } else if (intValue < 5) {
        return [UIColor green50];
    } else if (intValue < 10) {
        return [UIColor teal50];
    } else {
        return [UIColor blue50];
    }
}

- (UIColor *)lightTaskColor {
    NSInteger intValue = [self.value integerValue];
    if (intValue < -20) {
        return [UIColor darkRed100];
    } else if (intValue < -10) {
        return [UIColor red100];
    } else if (intValue < -1) {
        return [UIColor orange100];
    } else if (intValue < 1) {
        return [UIColor yellow100];
    } else if (intValue < 5) {
        return [UIColor green100];
    } else if (intValue < 10) {
        return [UIColor teal100];
    } else {
        return [UIColor blue100];
    }
}

+ (NSArray *)predicatesForTaskType:(NSString *)taskType withFilterType:(NSInteger)filterType {
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
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        df.locale = locale;
        NSString *dateString = [df stringFromDate:[NSDate date]];
        switch (filterType) {
            case TaskDailyFilterTypeAll: {
                return @[ [NSPredicate predicateWithFormat:@"type=='daily'"] ];
            }
            case TaskDailyFilterTypeDue: {
                NSArray *predicates =
                    @[ [NSPredicate predicateWithFormat:@"type=='daily' && completed == NO"] ];
                predicates = [predicates
                    arrayByAddingObject:[NSPredicate
                                            predicateWithFormat:@"(frequency == 'weekly' && %K == "
                                                                @"YES) || (frequency == 'daily')",
                                                                [dateString lowercaseString]]];
                return predicates;
            }
            case TaskDailyFilterTypeGrey: {
                NSArray *predicates = @[ [NSPredicate predicateWithFormat:@"type=='daily'"] ];
                predicates = [predicates
                    arrayByAddingObject:[NSPredicate
                                            predicateWithFormat:@"completed == YES || (frequency "
                                                                @"== 'weekly' && %K == NO) || "
                                                                @"(frequency == 'daily')",
                                                                [dateString lowercaseString]]];
                return predicates;
            }
        }
    } else if ([taskType isEqual:@"todo"]) {
        switch (filterType) {
            case TaskToDoFilterTypeActive: {
                return @[ [NSPredicate predicateWithFormat:@"type=='todo' && completed==NO"] ];
            }
            case TaskToDoFilterTypeDated: {
                return @[
                    [NSPredicate
                        predicateWithFormat:@"type=='todo' && completed==NO && duedate!=nil"]
                ];
            }
            case TaskToDoFilterTypeDone: {
                return @[ [NSPredicate predicateWithFormat:@"type=='todo' && completed==YES"] ];
            }
        }
    }
    return @[];
}

- (void)didSave {
    if ([CSSearchableIndex class]) {
        NSString *domainIdenntifier =
            [NSString stringWithFormat:@"com.habitrpg.habitica.tasks.%@", self.type];
        NSString *uniqueIdentifier =
            [NSString stringWithFormat:@"%@.%@", domainIdenntifier, self.id];
        if (self.inserted || self.updated) {
            CSSearchableItemAttributeSet *attributeSet;
            attributeSet = [[CSSearchableItemAttributeSet alloc]
                initWithItemContentType:(NSString *)kUTTypeImage];

            attributeSet.title = [self.text stringByReplacingEmojiCheatCodesWithUnicode];
            attributeSet.contentDescription =
                [self.notes stringByReplacingEmojiCheatCodesWithUnicode];

            CSSearchableItem *item =
                [[CSSearchableItem alloc] initWithUniqueIdentifier:uniqueIdentifier
                                                  domainIdentifier:domainIdenntifier
                                                      attributeSet:attributeSet];

            [[CSSearchableIndex defaultSearchableIndex]
                indexSearchableItems:@[ item ]
                   completionHandler:^(NSError *__nullable error){
                   }];
        } else if (self.deleted) {
            [[CSSearchableIndex defaultSearchableIndex]
                deleteSearchableItemsWithIdentifiers:@[ uniqueIdentifier ]
                                   completionHandler:^(NSError *_Nullable error){
                                   }];
        }
    }
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self observeCompleted];
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self observeCompleted];
}

- (void)observeCompleted {
    [self addObserver:self
           forKeyPath:@"completed"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
              context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"completed"]) {
        NSNumber *oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        NSNumber *newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([newValue boolValue] != [oldValue boolValue]) {
            for (Reminder *reminder in self.reminders) {
                if ([newValue boolValue]) {
                    if ([self.type isEqualToString:@"daily"]) {
                        [reminder removeTodaysNotifications];
                    } else {
                        [reminder removeAllNotifications];
                    }
                } else {
                    [reminder removeAllNotifications];
                    [reminder scheduleReminders];
                }
            }
        }
    }
}

- (void)willTurnIntoFault {
    [self removeObserver:self forKeyPath:@"completed"];
}

@end
