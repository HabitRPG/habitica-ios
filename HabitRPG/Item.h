//
//  Item.h
//  HabitRPG
//
//  Created by Phillip Thelen on 23/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSNumber *owned;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSString *dialog;
@property(nonatomic, retain) NSString *type;

@end
