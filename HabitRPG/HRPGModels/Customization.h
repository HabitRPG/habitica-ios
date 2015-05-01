//
//  Customization.h
//  Habitica
//
//  Created by Phillip Thelen on 01/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Customization : NSManagedObject

@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * purchased;
@property (nonatomic, retain) NSString * set;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) User *owner;

@end
