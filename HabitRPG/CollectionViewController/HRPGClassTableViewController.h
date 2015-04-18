//
//  HRPGClassCollectionViewController.h
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGClassTableViewController : UITableViewController <UIAlertViewDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@end
