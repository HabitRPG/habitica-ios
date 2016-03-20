//
//  ChatMessageLike+CoreDataProperties.h
//  Habitica
//
//  Created by Phillip Thelen on 09/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ChatMessageLike.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessageLike (CoreDataProperties)

@property(nullable, nonatomic, retain) NSString *userID;
@property(nullable, nonatomic, retain) ChatMessage *message;

@end

NS_ASSUME_NONNULL_END
