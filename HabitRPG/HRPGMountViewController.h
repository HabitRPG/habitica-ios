//
//  HRPGPetViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseCollectionViewController.h"

@interface HRPGMountViewController
    : HRPGBaseCollectionViewController<NSFetchedResultsControllerDelegate>

@property(nonatomic) NSString *mountName;
@property(nonatomic) NSString *mountType;
@property(nonatomic) NSString *mountColor;
@end
