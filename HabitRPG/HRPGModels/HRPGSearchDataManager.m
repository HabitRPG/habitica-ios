//
//  HRPGSearchDataManager.m
//  Habitica
//
//  Created by Kyle Fox on 7/25/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGSearchDataManager.h"

@implementation HRPGSearchDataManager

+ (HRPGSearchDataManager *)sharedManager {
    static HRPGSearchDataManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HRPGSearchDataManager alloc] init];
    });

    return sharedManager;
}

@end
