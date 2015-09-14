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

@implementation Task

@dynamic attribute;
@dynamic completed;
@dynamic dateCreated;
@dynamic down;
@dynamic id;
@dynamic notes;
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
@dynamic user;
@dynamic duedate;
@dynamic everyX;
@dynamic frequency;
@dynamic startDate;
@synthesize currentlyChecking;


- (BOOL)dueToday {
    return [self dueTodayWithOffset:0];
}

- (BOOL)dueTodayWithOffset:(NSInteger)offset {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (self.startDate) {
        NSDate *startDateAtMidnight;
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&startDateAtMidnight
                     interval:NULL forDate:self.startDate];
        if ([self.startDate compare:[NSDate date]] == NSOrderedDescending) {
            return NO;
        }
    }
    //get today + the custom offset the user uses
    NSDate *date = [NSDate date];
    NSDate *dateWithOffset = [date dateByAddingTimeInterval:-(offset*60*60)];
    if ([self.frequency isEqualToString:@"daily"]) {
        NSDate *startDate = [NSDate date];
        if (self.startDate) {
            startDate = self.startDate;
        }
        
        return ([[dateWithOffset daysSinceDate:startDate] integerValue] % [self.everyX integerValue]) == 0;
    } else {
        
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"EEEE"];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
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

- (NSDictionary *)getTagDictionary {
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.sharedManager.getManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
    for (Tag *tag in tags) {
        if ([self.tags containsObject:tag]) {
            [tagDictionary setObject:[NSNumber numberWithBool:YES] forKey:tag.id];
        } else {
            [tagDictionary setObject:[NSNumber numberWithBool:NO] forKey:tag.id];
        }
    }
    return tagDictionary;
}

- (void)setTagDictionary:(NSDictionary *)tagsDictionary {
    if (tagsDictionary.count == 0) {
        return;
    }
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appdelegate.sharedManager.getManagedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    NSError *error;
    NSArray *tags = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Tag *tag in tags) {
        NSNumber *val = tagsDictionary[tag.id];
        if (val != nil && ![val isKindOfClass:[NSNull class]]) {
            if ([val boolValue]) {
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
}

- (UIColor*) taskColor {
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

- (UIColor*) lightTaskColor {
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

+ (NSArray*)predicatesForTaskType:(NSString *) taskType withFilterType:(NSInteger)filterType {
    if ([taskType isEqual:@"habit"]) {
        switch (filterType) {
            case TaskHabitFilterTypeAll: {
                return @[[NSPredicate predicateWithFormat:@"type=='habit'"]];
            }
            case TaskHabitFilterTypeWeak: {
                return @[[NSPredicate predicateWithFormat:@"type=='habit' && value <= 0"]];
            }
            case TaskHabitFilterTypeStrong: {
                return @[[NSPredicate predicateWithFormat:@"type=='habit' && value > 0"]];
            }
        }
    } else if ([taskType isEqual:@"daily"]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"EEEE"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
        df.locale = locale;
        NSString *dateString = [df stringFromDate:[NSDate date]];
        switch (filterType) {
            case TaskDailyFilterTypeAll: {
                return @[[NSPredicate predicateWithFormat:@"type=='daily'"]];
            }
            case TaskDailyFilterTypeDue: {
                NSArray *predicates = @[[NSPredicate predicateWithFormat:@"type=='daily' && completed == NO"]];
                predicates = [predicates arrayByAddingObject:[NSPredicate predicateWithFormat:@"(frequency == 'weekly' && %K == YES) || (frequency == 'daily')", [dateString lowercaseString]]];
                return predicates;
            }
            case TaskDailyFilterTypeGrey: {
                NSArray *predicates = @[[NSPredicate predicateWithFormat:@"type=='daily'"]];
                predicates = [predicates arrayByAddingObject:[NSPredicate predicateWithFormat:@"completed == YES || (frequency == 'weekly' && %K == NO) || (frequency == 'daily')", [dateString lowercaseString]]];
                return predicates;
            }
        }
    } else if ([taskType isEqual:@"todo"]) {
        switch (filterType) {
            case TaskToDoFilterTypeActive: {
                return @[[NSPredicate predicateWithFormat:@"type=='todo' && completed==NO"]];
            }
            case TaskToDoFilterTypeDated: {
                return @[[NSPredicate predicateWithFormat:@"type=='todo' && completed==NO && duedate!=nil"]];
            }
            case TaskToDoFilterTypeDone: {
                return @[[NSPredicate predicateWithFormat:@"type=='todo' && completed==YES"]];
            }
        }
    }
    return @[];
}

@end
