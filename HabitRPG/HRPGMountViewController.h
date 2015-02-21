//
//  HRPGPetViewController.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGMountViewController : UICollectionViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)preferredContentSizeChanged:(NSNotification *)notification;
@property (nonatomic) NSString *mountName;
@property (nonatomic) NSString *mountType;
@property (nonatomic) NSString *mountColor;
@end
