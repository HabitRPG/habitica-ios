//
//  HRPGCustomizationCollectionViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 09/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "HRPGBaseCollectionViewController.h"

@interface HRPGCustomizationCollectionViewController
    : HRPGBaseCollectionViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, weak) User *user;
@property(nonatomic, strong) NSString *userKey;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *group;
@property(nonatomic, strong) NSString *entityName;

@end
