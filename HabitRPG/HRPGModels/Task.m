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
    NSMutableDictionary *tagDictionary = [NSMutableDictionary dictionary];
    for (Tag *tag in self.tags) {
        [tagDictionary setObject:[NSNumber numberWithBool:YES] forKey:tag.id];
    }
    return tagDictionary;
}

@end
