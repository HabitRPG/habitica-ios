//
//  HRPGPetMasterViewController.h
//  Habitica
//
//  Created by Phillip on 13/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGPetMasterViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)preferredContentSizeChanged:(NSNotification *)notification;


@end
