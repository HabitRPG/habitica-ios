//
//  TaskHistory+CoreDataProperties.m
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "TaskHistory+CoreDataProperties.h"

@implementation TaskHistory (CoreDataProperties)

+ (NSFetchRequest<TaskHistory *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"TaskHistory"];
}

@dynamic date;
@dynamic value;
@dynamic task;

@end
