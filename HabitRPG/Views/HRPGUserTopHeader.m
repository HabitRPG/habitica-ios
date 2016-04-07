//
//  HRPGUserTopHeader.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGUserTopHeader.h"
#import "HRPGAppDelegate.h"
#import <PDKeychainBindings.h>
#import "HRPGLabeledProgressBar.h"
#import "UIColor+Habitica.h"

@interface HRPGUserTopHeader ()

@property(weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *healthLabel;

@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *experienceLabel;

@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *magicLabel;

@property UIView *darkerBackground;

@property(weak, nonatomic) IBOutlet UILabel *levelLabel;

@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property(weak, nonatomic) IBOutlet UIImageView *classImageView;

@property(weak, nonatomic) IBOutlet UILabel *goldLabel;
@property(weak, nonatomic) IBOutlet UILabel *silverLabel;
@property(weak, nonatomic) IBOutlet UILabel *gemLabel;
@property(weak, nonatomic) IBOutlet UIView *gemView;
@property User *user;

@end

@implementation HRPGUserTopHeader

NSInteger barHeight = 5;
NSInteger rowHeight;
NSInteger rowWidth;
NSInteger margin = 3;
NSInteger rightMargin = 12;
NSInteger rowOffset = 16;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetUser:)
                                                     name:@"userChanged"
                                                   object:nil];
    }

    return self;
}

- (void)awakeFromNib {
    self.healthLabel.color = [UIColor red100];
    self.healthLabel.icon = [UIImage imageNamed:@"icon_health"];
    self.healthLabel.type = NSLocalizedString(@"Health", nil);

    self.experienceLabel.color = [UIColor yellow100];
    self.experienceLabel.icon = [UIImage imageNamed:@"icon_experience"];
    self.experienceLabel.type = NSLocalizedString(@"Experience", nil);

    self.magicLabel.color = [UIColor blue100];
    self.magicLabel.icon = [UIImage imageNamed:@"icon_magic"];
    self.magicLabel.type = NSLocalizedString(@"Mana", nil);

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.healthLabel.fontSize = 13;
        self.experienceLabel.fontSize = 13;
        self.magicLabel.fontSize = 13;
    } else {
        self.healthLabel.fontSize = 11;
        self.experienceLabel.fontSize = 11;
        self.magicLabel.fontSize = 11;
    }

    UIGestureRecognizer *recognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGemView)];
    [self.gemView addGestureRecognizer:recognizer];

    [self setData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];

    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [keyChain stringForKey:@"id"]]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[ sortDescriptor ];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext
                                              sectionNameKeyPath:nil
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

- (void)setData {
    self.user = [self getUser];
    [self.user setAvatarOnImageView:self.avatarImageView
                       withPetMount:YES
                           onlyHead:NO
                     withBackground:YES
                           useForce:YES];
    self.healthLabel.value = self.user.health;
    if ([self.user.maxHealth integerValue] > 0) {
        self.healthLabel.maxValue = self.user.maxHealth;
    }

    self.experienceLabel.value = self.user.experience;
    if ([self.user.nextLevel integerValue] > 0) {
        self.experienceLabel.maxValue = self.user.nextLevel;
    }

    if ([self.user.level integerValue] >= 10) {
        self.magicLabel.value = self.user.magic;
        if ([self.user.maxMagic integerValue] > 0) {
            self.magicLabel.maxValue = self.user.maxMagic;
        }
        self.magicLabel.hidden = NO;
    } else {
        self.magicLabel.hidden = YES;
    }

    self.usernameLabel.text = self.user.username;
    if ([self.user.contributorLevel integerValue] > 0) {
        self.usernameLabel.textColor = self.user.contributorColor;
        self.levelLabel.textColor = self.user.contributorColor;
    } else {
        self.usernameLabel.textColor = self.user.contributorColor;
        self.levelLabel.textColor = self.user.contributorColor;
    }
    self.levelLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"Level %@ %@", nil), self.user.level,
                                   NSLocalizedString([self.user.hclass capitalizedString], nil)];
    self.classImageView.image =
        [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@", self.user.hclass]];
    self.gemLabel.text =
        [[NSNumber numberWithFloat:[self.user.balance floatValue] * 4] stringValue];

    self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.user.gold integerValue]];
    int silver = ([self.user.gold floatValue] - [self.user.gold integerValue]) * 100;
    self.silverLabel.text = [NSString stringWithFormat:@"%d", silver];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [self setData];
}

- (User *)getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *)[self.fetchedResultsController
                objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }

    return nil;
}

- (void)resetUser:(NSNotification *)notification {
    self.fetchedResultsController = nil;
    [self setData];
}

- (void)showGemView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *)[storyboard
        instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    UIViewController *viewController =
        [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    if (!viewController.isViewLoaded || !viewController.view.window) {
        viewController = viewController.presentedViewController;
    }
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

@end
