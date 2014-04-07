//
//  Gear.h
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Gear : NSManagedObject

@property (nonatomic, retain) NSNumber * con;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * intelligence;
@property (nonatomic, retain) NSString * klass;
@property (nonatomic, retain) NSNumber * per;
@property (nonatomic, retain) NSNumber * str;

@end
