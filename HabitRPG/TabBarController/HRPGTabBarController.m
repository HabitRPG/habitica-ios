//
//  HRPGTabBarController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGTabBarController.h"
#import "UIColor+Habitica.h"
#import "TutorialSteps.h"
#if DEBUG
#import "FLEXManager.h"
#endif

@interface HRPGTabBarController ()

@property(strong, nonatomic) NSFetchedResultsController *taskFetchedResultsController;
@property(strong, nonatomic) NSFetchedResultsController *userFetchedResultsController;
@property(strong, nonatomic) NSFetchedResultsController *tutorialFetchedResultsController;

@end

@implementation HRPGTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSOperatingSystemVersion ios10 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10]) {
        [UITabBarItem appearance].badgeColor = [UIColor purple400];
    }

    UIImage *calendarImage = [UIImage imageNamed:@"tabbar_dailies"];

    UIGraphicsBeginImageContextWithOptions(
        CGSizeMake(calendarImage.size.width, calendarImage.size.height), NO, 0.0f);
    [calendarImage
        drawInRect:CGRectMake(0, 0, calendarImage.size.width, calendarImage.size.height)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName : [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold],
                                     NSParagraphStyleAttributeName : style};
    CGSize size = [dateString sizeWithAttributes:textAttributes];
    int offset = (calendarImage.size.width - size.width) / 2;
    [dateString drawInRect:CGRectMake(offset + 1, 13, 20, 20) withAttributes:textAttributes];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UITabBarItem *dailyItem = self.tabBar.items[1];
    dailyItem.image = resultImage;
    
    if ([dailyItem respondsToSelector:@selector(setBadgeColor:)]) {
        for (UITabBarItem *item in self.tabBar.items) {
            item.badgeColor = [UIColor red50];
        }
    }
    [self.tabBar setTintColor:[UIColor purple400]];

    
    [self updateTaskBadgeCount];
    [self updateUserBadges];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserID) name:@"userChanged" object:nil];

#if DEBUG
    UISwipeGestureRecognizer *swipe =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDebugMenu:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipe setDelaysTouchesBegan:YES];
    [swipe setNumberOfTouchesRequired:1];
    [[self view] addGestureRecognizer:swipe];
#endif
}

- (NSFetchedResultsController *)taskFetchedResultsController {
    if (_taskFetchedResultsController != nil) {
        return _taskFetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
    if (tabBarController.selectedTags == nil || [tabBarController.selectedTags count] == 0) {
        predicate = [NSPredicate predicateWithFormat:@"type!='habit' && completed==NO"];
    } else {
        predicate = [NSPredicate
            predicateWithFormat:@"type!='habit' && completed==NO && ANY tags IN[cd] %@",
                                self.selectedTags];
    }
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *orderDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *dateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors;
    sortDescriptors = @[ orderDescriptor, dateDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.taskFetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.taskFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _taskFetchedResultsController;
}

- (NSFetchedResultsController *)userFetchedResultsController {
    if (_userFetchedResultsController != nil) {
        return _userFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", [[HRPGManager sharedManager] getUser].id];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor =
    [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.userFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.userFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _userFetchedResultsController;
}

- (NSFetchedResultsController *)tutorialFetchedResultsController {
    if (_tutorialFetchedResultsController != nil) {
        return _tutorialFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TutorialSteps"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"wasShown == false && identifier IN %@", @[@"habiits", @"dailies", @"todos", @"rewards"]];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:YES];
    [fetchRequest setSortDescriptors:@[ sortDescriptor ]];
    
    NSFetchedResultsController *aFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.tutorialFetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.tutorialFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _userFetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    UINavigationController *navController = self.selectedViewController;
    if (navController.topViewController.isEditing) {
        [navController.topViewController setEditing:NO animated:YES];
    }
}

#if DEBUG

- (void)showDebugMenu:(UISwipeGestureRecognizer *)swipeRecognizer {
    if (swipeRecognizer.state == UIGestureRecognizerStateRecognized) {
        [[FLEXManager sharedManager] showExplorer];
    }
}
#endif

- (void)updateTaskBadgeCount {
    UITabBarItem *habitItem = self.tabBar.items[0];
    UITabBarItem *dailyItem = self.tabBar.items[1];
    UITabBarItem *todoItem = self.tabBar.items[2];
    UITabBarItem *rewardItem = self.tabBar.items[3];
    NSInteger habitBadgeCount = 0;
    NSInteger dailyBadgeCount = 0;
    NSInteger todoBadgeCount = 0;
    NSInteger rewardBadgeCount = 0;
    NSInteger appBadgeCount = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    
    for (Task *task in self.taskFetchedResultsController.fetchedObjects) {
        if ([task.type isEqualToString:@"daily"]) {
            if ([task dueTodayWithOffset:[[[HRPGManager sharedManager] getUser]
                                          .preferences.dayStart integerValue]]) {
                dailyBadgeCount++;
            }
        } else {
            if (task.duedate) {
                NSDateComponents *differenceValue = [calendar components:NSCalendarUnitDay
                                                                fromDate:today
                                                                  toDate:task.duedate
                                                                 options:0];
                if ([differenceValue day] <= 0) {
                    todoBadgeCount++;
                }
            }
        }
    }
    for (TutorialSteps *step in self.tutorialFetchedResultsController.fetchedObjects) {
        if ([step.identifier isEqualToString:@"habits"]) {
            habitBadgeCount += 1;
        } else if ([step.identifier isEqualToString:@"dailies"]) {
            dailyBadgeCount += 1;
        } else if ([step.identifier isEqualToString:@"todos"]) {
            todoBadgeCount += 1;
        } else if ([step.identifier isEqualToString:@"rewards"]) {
            rewardBadgeCount += 1;
        }
    }
    if (habitBadgeCount > 0) {
        habitItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)habitBadgeCount];
    } else {
        habitItem.badgeValue = nil;
    }
    
    if (dailyBadgeCount > 0) {
        dailyItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)dailyBadgeCount];
    } else {
        dailyItem.badgeValue = nil;
    }
    
    if (todoBadgeCount > 0) {
        todoItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)todoBadgeCount];
    } else {
        todoItem.badgeValue = nil;
    }
    
    if (rewardBadgeCount > 0) {
        rewardItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)rewardBadgeCount];
    } else {
        rewardItem.badgeValue = nil;
    }

    if ([HRPGManager sharedManager].useAppBadge) {
      appBadgeCount = dailyBadgeCount + todoBadgeCount;
    }

    [UIApplication sharedApplication].applicationIconBadgeNumber = appBadgeCount;
}

- (void)updateUserBadges {
    User *user = [[self.userFetchedResultsController fetchedObjects] lastObject];
    NSInteger badgeCount = 0;
    UITabBarItem *menuItem = self.tabBar.items[4];

    if (user) {
        if ([user.flags.habitNewStuff boolValue]) {
            badgeCount++;
        }
        if ([user.party.unreadMessages boolValue]) {
            badgeCount++;
        }
        if (user.inboxNewMessages.integerValue > 0) {
            badgeCount++;
        }
    }
    
    if (badgeCount > 0) {
        menuItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    } else {
        menuItem.badgeValue = nil;
    }
}

- (void)changeUserID {
    _userFetchedResultsController = nil;
    [self updateUserBadges];
}

- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller == self.userFetchedResultsController) {
        [self updateUserBadges];
    } else {
        [self updateTaskBadgeCount];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
