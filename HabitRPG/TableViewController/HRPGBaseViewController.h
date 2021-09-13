//
//  HRPGBaseViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TopHeaderCoordinator;
@protocol TopHeaderNavigationControllerProtocol;

@interface HRPGBaseViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property CGFloat viewWidth;
@property NSString *readableScreenName;

@property BOOL isVisible;

@property TopHeaderCoordinator *topHeaderCoordinator;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath;

- (void) populateText;

@end
