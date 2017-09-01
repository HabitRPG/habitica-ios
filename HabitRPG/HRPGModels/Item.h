//
//  Item.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface Item : NSManagedObject

@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSNumber *owned;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSString *dialog;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSNumber *isSubscriberItem;

@end
