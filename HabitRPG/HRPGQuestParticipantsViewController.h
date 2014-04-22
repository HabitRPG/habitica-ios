//
//  HRPGQuestParticipantsViewController.h
//  HabitRPG
//
//  Created by Phillip Thelen on 21/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGQuestParticipantsViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
