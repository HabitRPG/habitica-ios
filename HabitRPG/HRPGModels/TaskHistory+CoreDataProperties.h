//
//  TaskHistory+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "TaskHistory+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TaskHistory (CoreDataProperties)

+ (NSFetchRequest<TaskHistory *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, retain) Task *task;

@end

NS_ASSUME_NONNULL_END
