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


- (BOOL)dueToday {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE"];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier: @"en_US"];
    df.locale = locale;
    NSString *dateString = [df stringFromDate:[NSDate date]];
    return [[self valueForKey:[dateString lowercaseString]] boolValue];
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
        if (val != nil) {
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
        return [UIColor colorWithRed:0.824 green:0.113 blue:0.104 alpha:1.000];
    } else if (intValue < -10) {
        return [UIColor colorWithRed:0.906 green:0.328 blue:0.113 alpha:1.000];
    } else if (intValue < -1) {
        return [UIColor colorWithRed:0.966 green:0.517 blue:0.117 alpha:1.000];
    } else if (intValue < 1) {
        return [UIColor colorWithRed:0.847 green:0.597 blue:0.077 alpha:1.000];
    } else if (intValue < 5) {
        return [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
    } else if (intValue < 10) {
        return [UIColor colorWithRed:0.124 green:0.627 blue:0.755 alpha:1.000];
    } else {
        return [UIColor colorWithRed:0.231 green:0.442 blue:0.964 alpha:1.000];
    }
}

@end
