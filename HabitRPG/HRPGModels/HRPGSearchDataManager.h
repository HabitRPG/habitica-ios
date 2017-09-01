//
//  HRPGSearchDataManager.h
//  Habitica
//
//  Created by Kyle Fox on 7/25/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGSearchDataManager : NSObject

+ (HRPGSearchDataManager *)sharedManager;

@property(nonatomic, copy) NSString *searchString;

@end
