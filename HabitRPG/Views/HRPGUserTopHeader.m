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
#import "HRPGGemView.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "UIColor+Habitica.h"

@interface HRPGUserTopHeader ()

@property UIImageView *avatarImageView;

@property HRPGLabeledProgressBar *healthLabel;

@property HRPGLabeledProgressBar *experienceLabel;

@property HRPGLabeledProgressBar *magicLabel;

@property UIView *darkerBackground;

@property UILabel *levelLabel;

@property UILabel *usernameLabel;

@property HRPGGoldView *goldView;

@property HRPGGemView *gemView;

@property User *user;

@end

@implementation HRPGUserTopHeader

NSInteger barHeight = 5;
NSInteger rowHeight;
NSInteger rowWidth;
NSInteger margin = 3;
NSInteger rightMargin = 12;
NSInteger rowOffset = 130;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 115)];
        self.avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.avatarImageView];
        
        rowHeight = (self.frame.size.height-(margin*2))/4;
        rowWidth = self.frame.size.width-self.avatarImageView.frame.size.width-rightMargin;
        
        NIKFontAwesomeIconFactory *iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
        iconFactory.size = 15;
        iconFactory.renderingMode = UIImageRenderingModeAlwaysTemplate;
        
        self.healthLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, 0, rowWidth, rowHeight)];
        self.healthLabel.color = [UIColor red100];
        self.healthLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconHeart];
        self.healthLabel.type = NSLocalizedString(@"Health", nil);
        [self addSubview:self.healthLabel];
        
        self.experienceLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, rowHeight, rowWidth, rowHeight)];
        self.experienceLabel.color = [UIColor yellow100];
        self.experienceLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconStar];
        self.experienceLabel.type = NSLocalizedString(@"Experience", nil);
        [self addSubview:self.experienceLabel];
        
        self.magicLabel = [[HRPGLabeledProgressBar alloc] initWithFrame:CGRectMake(rowOffset, rowHeight*2, rowWidth, rowHeight)];
        self.magicLabel.color = [UIColor blue100];
        self.magicLabel.icon = [iconFactory createImageForIcon:NIKFontAwesomeIconFire];
        self.magicLabel.type = NSLocalizedString(@"Mana", nil);
        [self addSubview:self.magicLabel];
        
        self.darkerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 115, self.frame.size.width, self.frame.size.height-115)];
        self.darkerBackground.backgroundColor = [UIColor gray500];
        [self addSubview:self.darkerBackground];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height-40, 150, 20)];
        self.usernameLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        self.usernameLabel.textColor = [UIColor colorWithRed:0.3725 green:0.3725 blue:0.3725 alpha:1.0];
        [self addSubview:self.usernameLabel];
        
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.frame.size.height-22, 150, 20)];
        self.levelLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightLight];
        self.levelLabel.textColor = [UIColor colorWithRed:0.3725 green:0.3725 blue:0.3725 alpha:1.0];
        [self addSubview:self.levelLabel];
        
        self.goldView = [[HRPGGoldView alloc] initWithFrame:CGRectMake(rowOffset+(rowWidth+margin)/2, margin+rowHeight*3+(rowHeight-20)/2, (rowWidth-margin)/2, 20)];
        [self addSubview:self.goldView];
        
        self.gemView = [[HRPGGemView alloc] initWithFrame:CGRectMake(rowOffset, margin+rowHeight*3+(rowHeight-20)/2, (rowWidth-margin)/2, 20)];
        [self addSubview:self.gemView];
        
        [self setData];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(resetUser:)
         name:@"userChanged"
         object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    rowHeight = (self.frame.size.height-(margin*2))/4;
    rowWidth = self.frame.size.width-rowOffset-rightMargin;
    self.healthLabel.frame = CGRectMake(rowOffset, margin, rowWidth, rowHeight);
    self.experienceLabel.frame = CGRectMake(rowOffset, margin+rowHeight, rowWidth, rowHeight);
    self.magicLabel.frame = CGRectMake(rowOffset, margin+rowHeight*2, rowWidth, rowHeight);
    self.darkerBackground.frame = CGRectMake(0, 115, self.frame.size.width, self.frame.size.height-115);
    self.goldView.frame = CGRectMake(rowOffset+rowWidth-self.goldView.frame.size.width, self.goldView.frame.origin.y, self.goldView.frame.size.width, self.goldView.frame.size.height);
    self.gemView.frame = CGRectMake(self.goldView.frame.origin.x-self.gemView.frame.size.width-8, self.gemView.frame.origin.y, self.gemView.frame.size.width, self.gemView.frame.size.height);
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
    [self.user setAvatarOnImageView:self.avatarImageView withPetMount:YES onlyHead:NO withBackground:YES useForce:YES];
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
    self.levelLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Level %@ %@", nil), self.user.level, [self.user.hclass capitalizedString]];
    [self.goldView updateView:self.user.gold withDiffString:nil];
    [self.goldView sizeToFit];
    self.goldView.frame = CGRectMake(rowOffset+rowWidth-self.goldView.frame.size.width, self.goldView.frame.origin.y, self.goldView.frame.size.width, self.goldView.frame.size.height);
    [self.gemView updateViewWithGemcount:[NSNumber numberWithFloat:[self.user.balance floatValue]*4] withDiffString:nil];
    [self.gemView sizeToFit];
    self.gemView.frame = CGRectMake(self.goldView.frame.origin.x-self.gemView.frame.size.width-8, self.gemView.frame.origin.y, self.gemView.frame.size.width, self.gemView.frame.size.height);
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
