//
//  PushDevice+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PushDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface PushDevice (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *regId;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) User *owner;

@end

NS_ASSUME_NONNULL_END
