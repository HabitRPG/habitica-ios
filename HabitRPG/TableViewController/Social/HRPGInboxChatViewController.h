//
//  HRPGInboxChatViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "HRPGManager.h"

@interface HRPGInboxChatViewController : SLKTextViewController<NSFetchedResultsControllerDelegate>

@property NSString *userID;
@property NSString *username;
@property BOOL isPresentedModally;
@property(strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
