//
//  HRPGUserTopHeader.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGUserTopHeader.h"
#import "HRPGAppDelegate.h"
#import "HRPGLabeledProgressBar.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGUserTopHeader ()

@property(weak, nonatomic) IBOutlet AvatarView *avatarView;

@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *healthLabel;
@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *experienceLabel;
@property(weak, nonatomic) IBOutlet HRPGLabeledProgressBar *magicLabel;

@property UIView *darkerBackground;

@property(weak, nonatomic) IBOutlet UILabel *levelLabel;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property(weak, nonatomic) IBOutlet UIImageView *classImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *classImageViewWidthConstraint;


@property (weak, nonatomic) IBOutlet HRPGCurrencyCountView *gemView;
@property (weak, nonatomic) IBOutlet HRPGCurrencyCountView *goldView;
@property (weak, nonatomic) IBOutlet HRPGCurrencyCountView *hourglassView;
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
    self.healthLabel.icon = HabiticaIcons.imageOfHeartLightBg;
    self.healthLabel.type = NSLocalizedString(@"Health", nil);

    self.experienceLabel.color = [UIColor yellow100];
    self.experienceLabel.icon = HabiticaIcons.imageOfExperience;
    self.experienceLabel.type = NSLocalizedString(@"Experience", nil);

    self.magicLabel.color = [UIColor blue100];
    self.magicLabel.icon = HabiticaIcons.imageOfMagic;
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
    
    [self.goldView setAsGold];
    [self.gemView setAsGems];
    [self.hourglassView setAsHourglasses];
    
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGemView)];
    [self.gemView addGestureRecognizer:recognizer];

    self.usernameLabel.font = [CustomFontMetrics scaledSystemFontOfSize:16 compatibleWith:nil];
    self.levelLabel.font = [CustomFontMetrics scaledSystemFontOfSize:11 compatibleWith:nil];
    
    [self setData];
    [super awakeFromNib];
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

    [fetchRequest
        setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [AuthenticationManager shared].currentUserId]];

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

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = [HRPGManager sharedManager].getManagedObjectContext;
    }
    return _managedObjectContext;
}

- (void)setData {
    self.user = [self getUser];
    [self.avatarView setAvatar:self.user];
    self.healthLabel.value = self.user.health;
    if ([self.user.maxHealth integerValue] > 0) {
        self.healthLabel.maxValue = self.user.maxHealth;
    }

    self.experienceLabel.value = self.user.experience;
    if ([self.user.nextLevel integerValue] > 0) {
        self.experienceLabel.maxValue = self.user.nextLevel;
    }

    BOOL reachedLevelTen = [self.user.level integerValue] >= 10;
    if (reachedLevelTen && ![self.user.preferences.disableClass boolValue]) {
        self.magicLabel.value = self.user.magic;
        if ([self.user.maxMagic integerValue] > 0) {
            self.magicLabel.maxValue = self.user.maxMagic;
        }
        self.magicLabel.isActive = YES;
    } else {
        self.magicLabel.isActive = NO;
        self.magicLabel.value = @0;
        if (reachedLevelTen) {
            self.magicLabel.labelView.text = NSLocalizedString(@"Unlocks after selecting a class", nil);
        } else {
            self.magicLabel.labelView.text = NSLocalizedString(@"Unlocks at level 10", nil);
        }
    }

    self.usernameLabel.text = self.user.username;
    if ([self.user.contributorLevel integerValue] > 0) {
        self.usernameLabel.textColor = self.user.contributorColor;
        self.levelLabel.textColor = self.user.contributorColor;
    } else {
        self.usernameLabel.textColor = self.user.contributorColor;
        self.levelLabel.textColor = self.user.contributorColor;
    }
    if (![self.user.preferences.disableClass boolValue] && reachedLevelTen) {
        self.levelLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"Level %@ %@", nil), self.user.level,
         NSLocalizedString([self.user.hclass capitalizedString], nil)];
        NSString *habitClass = self.user.dirtyClass;
        if ([habitClass isEqualToString:@"warrior"]) {
            self.classImageView.image = [HabiticaIcons imageOfWarriorLightBg];
        } else if ([habitClass isEqualToString:@"wizard"]) {
            self.classImageView.image = [HabiticaIcons imageOfMageLightBg];
        } else if ([habitClass isEqualToString:@"healer"]) {
            self.classImageView.image = [HabiticaIcons imageOfHealerLightBg];
        } else if ([habitClass isEqualToString:@"rogue"]) {
            self.classImageView.image = [HabiticaIcons imageOfRogueLightBg];
        }
        self.classImageViewWidthConstraint.constant = 36;
    } else {
        self.levelLabel.text =
        [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), self.user.level];
        self.classImageView.image = nil;
        self.classImageViewWidthConstraint.constant = 0;
    }
    
    self.gemView.amount = [@([self.user.balance floatValue] * 4) integerValue];
    self.goldView.amount = [self.user.gold integerValue];
    self.hourglassView.amount = [self.user.subscriptionPlan.consecutiveTrinkets integerValue];
    self.hourglassView.hidden = ![self.user isSubscribed] && [self.user.subscriptionPlan.consecutiveTrinkets integerValue] == 0;
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
    UINavigationController *navigationController =
        [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    UIViewController *viewController =
        [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    if (!viewController.isViewLoaded || !viewController.view.window) {
        viewController = viewController.presentedViewController;
    }
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

@end
