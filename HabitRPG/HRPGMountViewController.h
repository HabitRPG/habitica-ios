//
//  HRPGPetViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseCollectionViewController.h"

@interface HRPGMountViewController
    : HRPGBaseCollectionViewController<NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic) NSString *mountName;
@property(nonatomic) NSString *mountType;
@property(nonatomic) NSString *mountColor;
@end
