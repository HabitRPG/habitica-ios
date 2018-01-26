//
//  HRPGTaskProtocol.h
//  Habitica
//
//  Created by Elliot Schrock on 10/28/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

@import Foundation;

@protocol HRPGTaskProtocol

@property (nullable, nonatomic, copy) NSString *attribute;
@property (nullable, nonatomic, copy) NSNumber *completed;
@property (nullable, nonatomic, copy) NSNumber *down;
@property (nullable, nonatomic, copy) NSString *id;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSNumber *order;
@property (nullable, nonatomic, copy) NSNumber *priority;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSNumber *up;
@property (nullable, nonatomic, copy) NSNumber *value;

@end
