//
//  HRPGUserBuyResponse.h
//  Habitica
//
//  Created by Phillip Thelen on 08/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGUserBuyResponse : NSObject

@property(nonatomic, retain) NSString *armoireType;
@property(nonatomic, retain) NSString *armoireKey;
@property(nonatomic, retain) NSString *armoireArticle;
@property(nonatomic, retain) NSString *armoireText;
@property(nonatomic, retain) NSNumber *armoireValue;
@property(nonatomic, retain) NSString *costumeArmor;
@property(nonatomic, retain) NSString *costumeBack;
@property(nonatomic, retain) NSString *costumeBody;
@property(nonatomic, retain) NSString *costumeEyewear;
@property(nonatomic, retain) NSString *costumeHead;
@property(nonatomic, retain) NSString *costumeHeadAccessory;
@property(nonatomic, retain) NSString *costumeShield;
@property(nonatomic, retain) NSString *costumeWeapon;
@property(nonatomic, retain) NSString *currentMount;
@property(nonatomic, retain) NSString *currentPet;
@property(nonatomic, retain) NSString *equippedArmor;
@property(nonatomic, retain) NSString *equippedBack;
@property(nonatomic, retain) NSString *equippedBody;
@property(nonatomic, retain) NSString *equippedEyewear;
@property(nonatomic, retain) NSString *equippedHead;
@property(nonatomic, retain) NSString *equippedHeadAccessory;
@property(nonatomic, retain) NSString *equippedShield;
@property(nonatomic, retain) NSString *equippedWeapon;
@property(nonatomic, retain) NSNumber *experience;
@property(nonatomic, retain) NSNumber *gold;
@property(nonatomic, retain) NSNumber *health;
@property(nonatomic, retain) NSNumber *level;
@property(nonatomic, retain) NSNumber *magic;
@end