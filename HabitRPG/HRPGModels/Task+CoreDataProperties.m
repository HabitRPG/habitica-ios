//
//  Task+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 17/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic attribute;
@dynamic challengeID;
@dynamic completed;
@dynamic dateCreated;
@dynamic down;
@dynamic duedate;
@dynamic everyX;
@dynamic frequency;
@dynamic friday;
@dynamic id;
@dynamic monday;
@dynamic notes;
@dynamic order;
@dynamic priority;
@dynamic saturday;
@dynamic startDate;
@dynamic streak;
@dynamic sunday;
@dynamic text;
@dynamic thursday;
@dynamic tuesday;
@dynamic type;
@dynamic up;
@dynamic value;
@dynamic wednesday;
@dynamic checklist;
@dynamic reminders;
@dynamic tags;
@dynamic user;

@end
