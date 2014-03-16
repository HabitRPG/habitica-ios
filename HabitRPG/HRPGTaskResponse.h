//
//  HRPGTaskResponse.h
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGTaskResponse : NSObject
@property (nonatomic, retain) NSNumber *delta;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSNumber *gold;
@property (nonatomic, retain) NSNumber *experience;
@property (nonatomic, retain) NSNumber *health;
@property (nonatomic, retain) NSNumber *magic;

@end
