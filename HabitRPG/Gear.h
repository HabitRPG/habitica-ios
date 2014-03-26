//
//  Gear.h
//  HabitRPG
//
//  Created by Phillip Thelen on 26/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Gear : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * con;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * klass;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * str;
@property (nonatomic, retain) NSNumber * intelligence;
@property (nonatomic, retain) NSNumber * per;

@end
