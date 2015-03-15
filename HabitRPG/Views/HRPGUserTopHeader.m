//
//  HRPGUserTopHeader.m
//  Habitica
//
//  Created by viirus on 12.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGUserTopHeader.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "User.h"
#import <PDKeychainBindings.h>
#import "HRPGLabeledProgressBar.h"
#import "HRPGGoldView.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"

@interface HRPGUserTopHeader ()

@property UIImageView *avatarImageView;

@property HRPGLabeledProgressBar *healthLabel;

@property HRPGLabeledProgressBar *experienceLabel;

@property HRPGLabeledProgressBar *magicLabel;

@property UILabel *levelLabel;

@property HRPGGoldView *goldView;

@property User *user;

@end

@implementation HRPGUserTopHeader

NSInteger barHeight = 5;
NSInteger rowHeight;
NSInteger rowWidth;
NSInteger margin = 5;
NSInteger rowOffset = 95;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        rowHeight = (self.frame.size.height-(margin*2))/3;
        rowWidth = self.frame.size.width-100;
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 90, 90)];
        [self addSubview:self.avatarImageView];
        
        NIKFontAwesomeIconFactory *iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
        iconFactory.size = 15;
        iconFactory.renderingMode = UIImageRenderingModeAlwaysTemplate;
        
        self.healthLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, margin, rowWidth, rowHeight)];
        self.healthLabel.color = [UIColor colorWithRed:0.987 green:0.129 blue:0.146 alpha:1.000];
        self.healthLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconHeart];
        [self addSubview:self.healthLabel];
        
        self.experienceLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, margin+rowHeight, rowWidth/2, rowHeight)];
        self.experienceLabel.color = [UIColor colorWithRed:0.870 green:0.686 blue:0.037 alpha:1.000];
        self.experienceLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconStar];
        [self addSubview:self.experienceLabel];
        
        self.magicLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset+(rowWidth+margin)/2, margin+rowHeight, rowWidth/2, rowHeight)];
        self.magicLabel.color = [UIColor blueColor];
        self.magicLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconFire];
        [self addSubview:self.magicLabel];
        
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(rowOffset, (margin+rowHeight)*2, (rowWidth-margin)/2, 20)];
        self.levelLabel.textColor = [UIColor blackColor];
        [self addSubview:self.levelLabel];
        
        self.goldView = [[HRPGGoldView alloc] initWithFrame:CGRectMake(rowOffset+(rowWidth+margin)/2, (margin+rowHeight)*2, (rowWidth-margin)/2, 20)];
        [self addSubview:self.goldView];
        
        [self setData];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(resetUser:)
         name:@"userChanged"
         object:nil];
    }
    
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"id == %@", [keyChain stringForKey:@"id"]]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
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

- (void) setData {
    self.user = [self getUser];
    [self.user setAvatarOnImageView:self.avatarImageView withPetMount:NO onlyHead:NO useForce:YES];
    self.healthLabel.value = [self.user.health integerValue];
    self.healthLabel.maxValue = [self.user.maxHealth integerValue];

    self.experienceLabel.value = [self.user.experience integerValue];
    self.experienceLabel.maxValue = [self.user.nextLevel integerValue];

    if ([self.user.level integerValue] >= 10) {
        self.magicLabel.value = [self.user.magic integerValue];
        self.magicLabel.maxValue = [self.user.maxMagic integerValue];
        self.magicLabel.hidden = NO;
    } else {
        self.magicLabel.hidden = YES;
    }
    
    self.levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Level %@", nil), self.user.level];
    [self.goldView updateRewardView:self.user.gold withDiffString:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    [self setData];
}

- (User*)getUser {
    if ([[self.fetchedResultsController sections] count] > 0) {
        if ([[self.fetchedResultsController sections][0] numberOfObjects] > 0) {
            return (User *) [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }
    }
    
    return nil;
}

- (void)resetUser:(NSNotification *)notification {
    self.fetchedResultsController = nil;
    [self setData];
}

@end
