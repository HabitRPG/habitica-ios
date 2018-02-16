//
//  ChatMessage.h
//  HabitRPG
//
//  Created by Phillip Thelen on 02/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "ChatMessageLike.h"
#import "User.h"

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

@property(nullable, nonatomic, retain) NSAttributedString *attributedText;

@end
