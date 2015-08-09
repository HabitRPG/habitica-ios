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

        NSDate *fromDate;
        NSDate *toDate;
        
        
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                     interval:NULL forDate:startDate];
        [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                     interval:NULL forDate:dateWithOffset];
        
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:fromDate toDate:toDate options:0];
        return ([difference day] % [self.everyX integerValue]) == 0;
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
        return [UIColor colorWithRed:0.702 green:0.314 blue:0.243 alpha:1.000];
    } else if (intValue < -10) {
        return [UIColor colorWithRed:0.780 green:0.275 blue:0.282 alpha:1.000];
    } else if (intValue < -1) {
        return [UIColor colorWithRed:0.906 green:0.569 blue:0.192 alpha:1.000];
    } else if (intValue < 1) {
        return [UIColor colorWithRed:0.973 green:0.780 blue:0.118 alpha:1.000];
    } else if (intValue < 5) {
        return [UIColor colorWithRed:0.498 green:0.710 blue:0.380 alpha:1.000];
    } else if (intValue < 10) {
        return [UIColor colorWithRed:0.443 green:0.604 blue:0.639 alpha:1.000];
    } else {
        return [UIColor colorWithRed:0.294 green:0.439 blue:0.910 alpha:1.000];
    }
}

- (UIColor*) lightTaskColor {
    NSInteger intValue = [self.value integerValue];
    if (intValue < -20) {
        return [UIColor colorWithRed:0.855 green:0.663 blue:0.620 alpha:1.000];
    } else if (intValue < -10) {
        return [UIColor colorWithRed:0.941 green:0.753 blue:0.753 alpha:1.000];
    } else if (intValue < -1) {
        return [UIColor colorWithRed:0.976 green:0.878 blue:0.749 alpha:1.000];
    } else if (intValue < 1) {
        return [UIColor colorWithRed:0.996 green:0.941 blue:0.757 alpha:1.000];
    } else if (intValue < 5) {
        return [UIColor colorWithRed:0.827 green:0.902 blue:0.776 alpha:1.000];
    } else if (intValue < 10) {
        return [UIColor colorWithRed:0.780 green:0.851 blue:0.867 alpha:1.000];
    } else {
        return [UIColor colorWithRed:0.749 green:0.816 blue:0.980 alpha:1.000];
    }
}

@end
