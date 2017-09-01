//
//  Customization.h
//  Habitica
//
//  Created by Phillip Thelen on 01/05/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class User;

@interface Customization : NSManagedObject

@property(nonatomic, retain) NSString *group;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSNumber *price;
@property(nonatomic, retain) NSNumber *purchased;
@property(nonatomic, retain) NSNumber *purchasable;
@property(nonatomic, retain) NSString *set;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) User *owner;

- (NSString *)getImageNameForUser:(User *)user;
- (NSString *)getPath;
@end
