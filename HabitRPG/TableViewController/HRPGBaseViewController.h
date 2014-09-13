//
//  HRPGBaseViewController.h
//  RabbitRPG
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGBaseViewController : UITableViewController

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (void)preferredContentSizeChanged:(NSNotification *)notification;

-(void)addActivityCounter;
-(void)removeActivityCounter;
@property NSInteger activityCounter;
- (NSDictionary *)markdownAttributes;
@end
