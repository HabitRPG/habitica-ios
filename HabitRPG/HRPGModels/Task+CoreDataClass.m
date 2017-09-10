//
//  Task+CoreDataClass.m
//  Habitica
//
//  Created by Phillip Thelen on 17/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Task+CoreDataClass.h"
#import "ChecklistItem.h"
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

- (void)addChecklistObject:(ChecklistItem *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checklist];
    [tempSet addObject:value];
    self.checklist = tempSet;
}

- (void)removeChecklistObject:(ChecklistItem *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.checklist];
    [tempSet removeObject:value];
    self.checklist = tempSet;
}

- (void)addRemindersObject:(Reminder *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.reminders];
    [tempSet addObject:value];
    self.reminders = tempSet;
}

- (void)removeRemindersObject:(Reminder *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.reminders];
    [tempSet removeObject:value];
    self.reminders = tempSet;
}

- (BOOL)dueToday {
    if (self.isDue) {
        return [self.isDue boolValue];
    }
    return [self dueOnDate:[NSDate date] withOffset:0];
}

- (BOOL)dueTodayWithOffset:(NSInteger)offset {
    if (self.isDue) {
        return [self.isDue boolValue];
    }
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
        if ([startDateAtMidnight compare:[NSDate date]] == NSOrderedDescending) {
            return NO;
        }
    }
    // get today + the custom offset the user uses
    NSDate *dateWithOffset = [date dateByAddingTimeInterval:-(offset * 60 * 60)];
    if ([[dateWithOffset daysSinceDate:[NSDate date]] integerValue] == 0) {
        if (self.isDue) {
            return [self.isDue boolValue];
        }
    } else if (self.nextDue) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        for (NSString *dateString in self.nextDue) {
            NSDate *date = [dateFormatter dateFromString:dateString];
            if ([[dateWithOffset daysSinceDate:date] integerValue] == 0) {
                return YES;
            }
        }
        return NO;
    }
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

- (NSArray *)tagArray {
    NSMutableArray *tagArray = [NSMutableArray array];
    for (Tag *tag in self.tags) {
        [tagArray addObject:tag.id];
    }
    return tagArray;
}

- (void)setTagArray:(NSArray *)tagArray {
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
    self.observesCompleted = YES;
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
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
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
    if (self.observesCompleted) {
        [self removeObserver:self forKeyPath:@"completed"];
        self.observesCompleted = NO;
    }
}

- (BOOL)allWeekdaysInactive {
    return ![self.monday boolValue] && ![self.tuesday boolValue] && ![self.wednesday boolValue] && ![self.thursday boolValue] && ![self.friday boolValue] && ![self.saturday boolValue] && ![self.sunday boolValue];
}

@end
