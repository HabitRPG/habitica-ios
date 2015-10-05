//
//  HRPGAvatarSetupViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAvatarSetupViewController.h"
#import "HRPGCustomizationSelectionView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Habitica.h"
#import "Customization.h"
#import "HRPGTaskSetupTableViewController.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"
#import "HRPGTypingLabel.h"

@interface HRPGAvatarSetupViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property UIImageView *justinView;
@property UIImageView *avatarView;

@property UILabel *welcomeLabel;
@property HRPGTypingLabel *welcomeDescriptionLabel;
@property UILabel *descriptionlabel;
@property UILabel *instructionLabel;

@property HRPGCustomizationSelectionView *customizationSelectionView;
@property UISegmentedControl *bodySizeView;
@property HRPGCustomizationSelectionView *bangsSelectionView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property UIButton *welcomeButton;

@property NSString *welcomeDescriptionString;
@property NSString *avatarDescriptionString;

@property BOOL isSkipping;

@end

@implementation HRPGAvatarSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeDescriptionString = NSLocalizedString(@"Welcome to Habitica, where advancing in the game will improve your real life! As you accomplish real-world goals, you'll unlock equipment, pets, quests, and more.", nil);
    self.avatarDescriptionString = NSLocalizedString(@"First, you need an avatar in the game to represent you! The things you do in real life will affect your avatar's health, experience level, and gold.", nil);
    
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsWelcome:
            [self setupWelcomeStep];
            break;
        case HRPGAvatarSetupStepsShirt:
            [self setupShirtStep];
            break;
        default:
            [self setupCustomizationStep];
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.user) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *manager = appdelegate.sharedManager;
        self.user = [manager getUser];
    }
    
    if ([self.user.lastSetupStep integerValue] > self.currentStep) {
        self.isSkipping = YES;
        [self nextStep:nil];
    } else {
        self.isSkipping = NO;
        NSError *error;
        self.user.lastSetupStep = [NSNumber numberWithLong:self.currentStep];
        [self.managedObjectContext saveToPersistentStore:&error];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.currentStep == HRPGAvatarSetupStepsWelcome && self.welcomeDescriptionLabel.text.length == 0) {
        self.welcomeDescriptionLabel.text = self.welcomeDescriptionString;
    }
}

- (void)viewWillLayoutSubviews {
    CGFloat height;
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsWelcome:
            [super viewWillLayoutSubviews];
            self.justinView.frame = CGRectMake((self.mainScrollView.frame.size.width-84)/2, self.mainScrollView.frame.size.height/2-120, 84, 120);
            CGFloat descriptionHeight = [self.welcomeDescriptionString boundingRectWithSize:CGSizeMake(self.mainScrollView.frame.size.width-40, MAXFLOAT)
                                                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                 attributes:@{
                                                                                                              NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                              }
                                                                                                    context:nil].size.height+10;
            self.welcomeLabel.frame = CGRectMake(0, self.justinView.frame.origin.y - 50, self.mainScrollView.frame.size.width, 30);
            self.welcomeDescriptionLabel.frame = CGRectMake(20, self.justinView.frame.origin.y+160, self.mainScrollView.frame.size.width-40, descriptionHeight);
            self.welcomeButton.frame = CGRectMake(20, self.welcomeDescriptionLabel.frame.origin.y+descriptionHeight+20, self.mainScrollView.frame.size.width-20, 60);
            height = self.welcomeButton.frame.origin.y+self.welcomeButton.frame.size.height;
            break;
        default:
            self.avatarView.frame = CGRectMake(10, 40, self.mainScrollView.frame.size.width-20, 120);
            CGFloat instructionHeight = [self.instructionLabel.text boundingRectWithSize:CGSizeMake(self.mainScrollView.frame.size.width-40, MAXFLOAT)
                                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                                attributes:@{
                                                                                             NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                             }
                                                                                   context:nil].size.height+10;
            if (self.descriptionlabel) {
                CGFloat descriptionHeight = [self.avatarDescriptionString boundingRectWithSize:CGSizeMake(self.mainScrollView.frame.size.width-40, MAXFLOAT)
                                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                                    attributes:@{
                                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16.0]
                                                                                                 }
                                                                                       context:nil].size.height+10;
                self.descriptionlabel.frame = CGRectMake(20, self.avatarView.frame.origin.y+140, self.mainScrollView.frame.size.width-40, descriptionHeight);
                self.instructionLabel.frame = CGRectMake(20, self.descriptionlabel.frame.origin.y+self.descriptionlabel.frame.size.height+20, self.mainScrollView.frame.size.width-40, instructionHeight);
            } else {
                self.instructionLabel.frame = CGRectMake(20, self.avatarView.frame.origin.y+self.avatarView.frame.size.height+20, self.mainScrollView.frame.size.width-40, instructionHeight);
            }
            self.customizationSelectionView.frame = CGRectMake(20, self.instructionLabel.frame.origin.y+self.instructionLabel.frame.size.height+20, self.mainScrollView.frame.size.width-40, 250);
            [self.customizationSelectionView layoutSubviews];
            [self.customizationSelectionView sizeToFit];
            height = self.customizationSelectionView.frame.origin.y+self.customizationSelectionView.frame.size.height;
            if (self.bodySizeView) {
                self.bodySizeView.frame = CGRectMake((self.mainScrollView.frame.size.width/2)-50, self.customizationSelectionView.frame.origin.y+self.customizationSelectionView.frame.size.height+32, 100, 30);
                height = self.bodySizeView.frame.origin.y+self.bodySizeView.frame.size.height;
            }
            if (self.bangsSelectionView) {
                self.bangsSelectionView.frame = CGRectMake(20, self.customizationSelectionView.frame.origin.y+self.customizationSelectionView.frame.size.height+60, self.mainScrollView.frame.size.width-40, 250);
                [self.customizationSelectionView layoutSubviews];
                [self.customizationSelectionView sizeToFit];
                height = self.bangsSelectionView.frame.origin.y+self.bangsSelectionView.frame.size.height;
            }
            
            break;
    }
    [super viewWillLayoutSubviews];
    CGSize oldContentSize = self.mainScrollView.contentSize;
    oldContentSize.height = height;
    self.mainScrollView.contentSize = oldContentSize;
}

- (void)setupWelcomeStep {
    self.backButton.hidden = YES;
    self.nextButton.hidden = YES;
    
    self.welcomeLabel = [[UILabel alloc] init];
    self.welcomeLabel.font = [UIFont systemFontOfSize:26.0];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    self.welcomeLabel.text = NSLocalizedString(@"Welcome", nil);
    [self.mainScrollView addSubview:self.welcomeLabel];
    
    self.justinView = [[UIImageView alloc] init];
    [self.justinView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/npc_justin.png"]];
    [self.mainScrollView addSubview:self.justinView];
    
    self.welcomeDescriptionLabel = [[HRPGTypingLabel alloc] init];
    self.welcomeDescriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.welcomeDescriptionLabel.font = [UIFont systemFontOfSize:16.0];
    [self.mainScrollView addSubview:self.welcomeDescriptionLabel];
    
    self.welcomeButton = [[UIButton alloc] init];
    [self.welcomeButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    [self.welcomeButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
    [self.welcomeButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:self.welcomeButton];
}

- (void)setupShirtStep {
    [self setupCustomizationStep];
    
    self.bodySizeView = [[UISegmentedControl alloc] initWithItems:@[@"Slim", @"Broad"]];
    [self.mainScrollView addSubview:self.bodySizeView];
    if ([self.user.size isEqualToString:@"slim"]) {
        [self.bodySizeView setSelectedSegmentIndex:0];
    } else {
        [self.bodySizeView setSelectedSegmentIndex:1];
    }
    [self.bodySizeView addTarget:self action:@selector(userSizeChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) setupCustomizationStep {
    self.avatarView = [[UIImageView alloc] init];
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:NO];
    self.avatarView.contentMode = UIViewContentModeCenter;
    self.avatarView.userInteractionEnabled = NO;
    [self.mainScrollView addSubview:self.avatarView];
    
    NSString *instructionString;
    NSPredicate *predicate;
    NSString *selectedItem;
    CGFloat verticalCutoff;
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsSkin:
            instructionString = NSLocalizedString(@"Choose a skin color!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'skin'"];
            verticalCutoff = 0.85;
            selectedItem = self.user.skin;
            break;
        case HRPGAvatarSetupStepsShirt:
            instructionString = NSLocalizedString(@"Choose your outfit! (You'll unlock more outfits soon.)", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'shirt'"];
            verticalCutoff = 1.1;
            selectedItem = self.user.shirt;
            break;
        case HRPGAvatarSetupStepsHairStyle:
            instructionString = NSLocalizedString(@"Choose a hairstyle!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'base'"];
            selectedItem = self.user.hairBase;
            verticalCutoff = 0.85;
            [self.mainScrollView addSubview:self.customizationSelectionView];
        
            break;
        case HRPGAvatarSetupStepsHairColor:
            instructionString = NSLocalizedString(@"Choose a hair color!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'color'"];
            selectedItem = self.user.hairColor;
            verticalCutoff = 0.77;
            break;
    }
    
    self.descriptionlabel = [[UILabel alloc] init];
    self.descriptionlabel.numberOfLines = 0;
    self.descriptionlabel.text = self.avatarDescriptionString;
    [self.mainScrollView addSubview:self.descriptionlabel];
    
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.numberOfLines = 0;
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.text = instructionString;
    [self.mainScrollView addSubview:self.instructionLabel];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    NSError *error;
    
    self.customizationSelectionView = [[HRPGCustomizationSelectionView alloc] init];
    self.customizationSelectionView.verticalCutoff = verticalCutoff;
    self.customizationSelectionView.user = self.user;
    self.customizationSelectionView.selectedItem = selectedItem;
    self.customizationSelectionView.items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    __weak HRPGAvatarSetupViewController *weakSelf = self;
    self.customizationSelectionView.selectionAction = ^(Customization *selectedItem) {
        switch (weakSelf.currentStep) {
            case HRPGAvatarSetupStepsSkin:
                weakSelf.user.skin = selectedItem.name;
                break;
            case HRPGAvatarSetupStepsShirt:
                weakSelf.user.shirt = selectedItem.name;
                break;
            case HRPGAvatarSetupStepsHairStyle:
                weakSelf.user.hairBase = selectedItem.name;
                break;
            case HRPGAvatarSetupStepsHairColor:
                weakSelf.user.hairColor = selectedItem.name;
                break;
        }
        [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
    };
    [self.mainScrollView addSubview:self.customizationSelectionView];
    
    if (self.currentStep == HRPGAvatarSetupStepsHairStyle) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:20];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'bangs'"]];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];

        NSError *error;
        self.bangsSelectionView = [[HRPGCustomizationSelectionView alloc] init];
        self.bangsSelectionView.verticalCutoff = verticalCutoff;
        self.bangsSelectionView.user = self.user;
        self.bangsSelectionView.selectedItem = self.user.hairBangs;
        self.bangsSelectionView.items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        __weak HRPGAvatarSetupViewController *weakSelf = self;
        self.bangsSelectionView.selectionAction = ^(Customization *selectedItem) {
            weakSelf.user.hairBangs = selectedItem.name;
            [weakSelf.user setAvatarOnImageView:weakSelf.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];
        };
        [self.mainScrollView addSubview:self.bangsSelectionView];
    }
}

- (IBAction)nextStep:(id)sender {
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    
    NSDictionary *updateDict;
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsSkin:
            updateDict = @{@"preferences.skin": self.user.skin};
            break;
        case HRPGAvatarSetupStepsShirt:
            updateDict = @{@"preferences.shirt": self.user.shirt, @"preferences.size": self.user.size};
            break;
        case HRPGAvatarSetupStepsHairStyle:
            updateDict = @{@"preferences.hair.base": self.user.hairBase, @"preferences.hair.bangs": self.user.hairBangs};
            break;
        case HRPGAvatarSetupStepsHairColor:
            updateDict = @{@"preferences.hair.color": self.user.hairColor};
            break;
    }
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *manager = appdelegate.sharedManager;
    [manager updateUser:updateDict onSuccess:^() {
        
    }onError:^() {
        
    }];
    
    if (self.currentStep != HRPGAvatarSetupStepsShirt) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HRPGAvatarSetupViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"AvatarSetupViewController"];
        dest.currentStep = self.currentStep+1;
        dest.user = self.user;
        dest.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:dest animated:!self.isSkipping];
    } else {
        [self performSegueWithIdentifier:@"TaskSetupSegue" sender:self];
    }
}


- (IBAction)previousStep:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:self.currentStep-1];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)skipSetup:(id)sender {
    self.user.lastSetupStep = [NSNumber numberWithInteger:HRPGAvatarSetupStepsTasks];
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    [self performSegueWithIdentifier:@"MainSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TaskSetupSegue"]) {
        HRPGTaskSetupTableViewController *destinationController = segue.destinationViewController;
        destinationController.user = self.user;
        destinationController.managedObjectContext = self.managedObjectContext;
        destinationController.currentStep = HRPGAvatarSetupStepsTasks;
    }
}

- (IBAction)userSizeChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.user.size = @"slim";
    } else {
        self.user.size = @"broad";
    }
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:YES];

}

@end
