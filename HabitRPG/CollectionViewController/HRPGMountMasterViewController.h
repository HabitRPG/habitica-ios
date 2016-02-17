//
//  HRPGMountMasterViewController.h
//  Habitica
//
//  Created by Phillip on 13/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseCollectionViewController.h"

@interface HRPGMountMasterViewController : HRPGBaseCollectionViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

- (void)preferredContentSizeChanged:(NSNotification *)notification;


@end
