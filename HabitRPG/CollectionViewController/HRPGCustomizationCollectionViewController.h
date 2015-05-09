//
//  HRPGCustomizationCollectionViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 09/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HRPGCustomizationCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, weak) User *user;
@property(nonatomic, strong) NSString *userKey;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *group;

- (void)preferredContentSizeChanged:(NSNotification *)notification;


@end
