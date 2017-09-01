//
//  Egg.h
//  HabitRPG
//
//  Created by Phillip Thelen on 26/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "BuyableItem.h"

@interface Egg : BuyableItem

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *adjective;
@property(nonatomic, retain) NSNumber *value;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *notes;
@property(nonatomic, retain) NSString *mountText;
@property(nonatomic, retain) NSString *dialog;

@end
