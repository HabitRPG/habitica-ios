//
//  Reminder+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 23/12/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Reminder.h"

NS_ASSUME_NONNULL_BEGIN

@interface Reminder (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) Task *task;
@property (nullable, nonatomic, retain) NSString *id;

@end

NS_ASSUME_NONNULL_END
