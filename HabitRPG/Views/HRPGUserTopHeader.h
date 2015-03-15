//
//  HRPGUserTopHeader.h
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "User.h"

@interface HRPGUserTopHeader : UIView <NSFetchedResultsControllerDelegate>

@property NSArray *selectedTags;@property (nonatomic)  HRPGManager *sharedManager;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
