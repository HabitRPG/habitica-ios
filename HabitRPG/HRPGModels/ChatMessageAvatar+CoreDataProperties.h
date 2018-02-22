//
//  ChatMessageAvatar+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 20.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//
//

#import "ChatMessageAvatar+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageAvatar (CoreDataProperties)

+ (NSFetchRequest<ChatMessageAvatar *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *background;
@property (nullable, nonatomic, copy) NSString *chair;
@property (nullable, nonatomic, copy) NSString *currentMount;
@property (nullable, nonatomic, copy) NSString *currentPet;
@property (nullable, nonatomic, copy) NSString *hairBangs;
@property (nullable, nonatomic, copy) NSString *hairBase;
@property (nullable, nonatomic, copy) NSString *hairBeard;
@property (nullable, nonatomic, copy) NSString *hairColor;
@property (nullable, nonatomic, copy) NSString *hairFlower;
@property (nullable, nonatomic, copy) NSString *hairMustache;
@property (nullable, nonatomic, copy) NSString *shirt;
@property (nullable, nonatomic, copy) NSString *size;
@property (nullable, nonatomic, copy) NSString *skin;
@property (nullable, nonatomic, copy) NSNumber *sleep;
@property (nullable, nonatomic, copy) NSNumber *useCostume;
@property (nullable, nonatomic, retain) Outfit *costume;
@property (nullable, nonatomic, retain) Outfit *equipped;
@property (nullable, nonatomic, retain) ChatMessage *message;

@end

NS_ASSUME_NONNULL_END
