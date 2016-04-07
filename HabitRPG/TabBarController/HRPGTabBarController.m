//
//  HRPGTabBarController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 16/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGTabBarController.h"
#import "HRPGAppDelegate.h"
#import "NIKFontAwesomeIconFactory.h"
#import "UIColor+Habitica.h"
#if DEBUG
#import "FLEXManager.h"
#endif

@interface HRPGTabBarController ()

@end

@implementation HRPGTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];

    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];

    UITabBarItem *item0 = self.tabBar.items[0];
    item0.image = [factory createImageForIcon:NIKFontAwesomeIconArrowsV];

    UIImage *calendarImage = [factory createImageForIcon:NIKFontAwesomeIconCalendarO];

    UIGraphicsBeginImageContextWithOptions(
        CGSizeMake(calendarImage.size.width, calendarImage.size.height), NO, 0.0f);
    [calendarImage
        drawInRect:CGRectMake(0, 0, calendarImage.size.width, calendarImage.size.height)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
    CGSize size = [dateString sizeWithAttributes:textAttributes];
    int offset = (calendarImage.size.width - size.width) / 2;
    [dateString drawInRect:CGRectMake(offset + 0.5f, 8, 20, 20) withAttributes:textAttributes];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UITabBarItem *item1 = self.tabBar.items[1];
    item1.image = resultImage;

    UITabBarItem *item2 = self.tabBar.items[2];
    item2.image = [factory createImageForIcon:NIKFontAwesomeIconCheckSquareO];

    UITabBarItem *item3 = self.tabBar.items[3];
    item3.image = [factory createImageForIcon:NIKFontAwesomeIconTrophy];

    UITabBarItem *item4 = self.tabBar.items[4];
    item4.image = [factory createImageForIcon:NIKFontAwesomeIconBars];

    [self.tabBar setTintColor:[UIColor purple400]];

    [self updateDailyBadge];

#if DEBUG
    UISwipeGestureRecognizer *swipe =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showDebugMenu:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipe setDelaysTouchesBegan:YES];
    [swipe setNumberOfTouchesRequired:1];
    [[self view] addGestureRecognizer:swipe];
#endif
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    NSPredicate *predicate;
    HRPGTabBarController *tabBarController = (HRPGTabBarController *)self.tabBarController;
    if (tabBarController.selectedTags == nil || [tabBarController.selectedTags count] == 0) {
        predicate = [NSPredicate predicateWithFormat:@"type=='daily' && completed==NO"];
    } else {
        predicate = [NSPredicate
            predicateWithFormat:@"type=='daily' && completed==NO && ANY tags IN[cd] %@",
                                self.selectedTags];
    }
    [fetchRequest setPredicate:predicate];

    NSSortDescriptor *orderDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSSortDescriptor *dateDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors;
    NSString *sectionKey;
    sortDescriptors = @[ orderDescriptor, dateDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:sectionKey
                                                       cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate =
            (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = self.sharedManager.getManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    UINavigationController *navController = (UINavigationController *)self.selectedViewController;
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

- (void)updateDailyBadge {
    UITabBarItem *dailyItem = self.tabBar.items[1];
    NSInteger badgeCount = 0;
    for (Task *task in self.fetchedResultsController.fetchedObjects) {
        if ([task dueTodayWithOffset:[[self.sharedManager getUser]
                                             .preferences.dayStart integerValue]]) {
            badgeCount++;
        }
    }
    if (badgeCount > 0) {
        dailyItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeCount];
    } else {
        dailyItem.badgeValue = nil;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [self updateDailyBadge];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
