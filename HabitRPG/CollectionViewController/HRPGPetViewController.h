//
//  HRPGPetViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseCollectionViewController.h"

@interface HRPGPetViewController
    : HRPGBaseCollectionViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic) NSString *petName;
@property(nonatomic) NSString *petType;
@property(nonatomic) NSString *petColor;

@end
