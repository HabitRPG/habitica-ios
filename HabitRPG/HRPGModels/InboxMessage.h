//
//  InboxMessage.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

NS_ASSUME_NONNULL_BEGIN

@interface InboxMessage : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "InboxMessage+CoreDataProperties.h"
