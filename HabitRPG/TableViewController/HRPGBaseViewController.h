//
//  HRPGBaseViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGBaseViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic)  HRPGManager *sharedManager;
@property CGFloat viewWidth;
@property NSString *readableScreenName;

- (void)preferredContentSizeChanged:(NSNotification *)notification;

@property NSInteger activityCounter;
- (NSDictionary *)markdownAttributes;

@end
