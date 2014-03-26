//
//  Egg.h
//  HabitRPG
//
//  Created by Phillip Thelen on 26/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Egg : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * adjective;
@property (nonatomic) BOOL canBuy;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * mountText;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * dialog;

@end
