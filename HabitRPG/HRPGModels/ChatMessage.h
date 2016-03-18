//
//  ChatMessage.h
//  HabitRPG
//
//  Created by Phillip Thelen on 02/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "ChatMessageLike.h"

@class Group;

@interface ChatMessage : NSManagedObject

@property(nonatomic, retain) NSString *id;
@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSDate *timestamp;
@property(nonatomic, retain) NSString *user;
@property(nonatomic, retain) NSString *uuid;
@property(nonatomic, retain) Group *group;
@property(nonatomic, retain) User *userObject;
@property(nonatomic, retain) NSNumber *contributorLevel;
@property(nonatomic, retain) NSString *backerNpc;
@property(nonatomic, retain) NSSet *likes;

@property NSAttributedString *attributedText;

- (UIColor *)contributorColor;

@end
