//
//  HRPGPetViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseCollectionViewController.h"

@interface HRPGPetViewController : HRPGBaseCollectionViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) NSString *petName;
@property (nonatomic) NSString *petType;
@property (nonatomic) NSString *petColor;

@end
