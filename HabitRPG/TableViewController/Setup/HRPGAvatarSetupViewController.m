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

@interface HRPGAvatarSetupViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property UIImageView *justinView;
@property UIImageView *avatarView;

@property UILabel *welcomeLabel;
@property UILabel *descriptionlabel;
@property UILabel *instructionLabel;

@property HRPGCustomizationSelectionView *customizationSelectionView;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property UIButton *welcomeButton;

@property NSString *welcomeDescriptionString;

@property BOOL isSkipping;

@end

@implementation HRPGAvatarSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.welcomeDescriptionString = NSLocalizedString(@"Welcome to Habitica, where advancing in the game will improve your real life! As you accomplish real-world goals, you'll unlock equipment, pets, quests, and more.", nil);
    
    switch (self.currentStep) {
        case HRPGAvatarSetupStepsWelcome:
            [self setupWelcomeStep];
            break;
        default:
            [self setupCustomizationStep];
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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

- (void)viewWillLayoutSubviews {
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
            self.descriptionlabel.frame = CGRectMake(20, self.justinView.frame.origin.y+160, self.mainScrollView.frame.size.width-40, descriptionHeight);
            self.welcomeButton.frame = CGRectMake(20, self.descriptionlabel.frame.origin.y+descriptionHeight+20, self.mainScrollView.frame.size.width-20, 60);
            break;
        default:
            self.justinView.frame = CGRectMake(20, 80, self.mainScrollView.frame.size.width/2-10, 120);
            self.avatarView.frame = CGRectMake(self.mainScrollView.frame.size.width/2-10, 80, self.mainScrollView.frame.size.width/2-10, 120);
            self.instructionLabel.frame = CGRectMake(20, self.avatarView.frame.origin.y+self.avatarView.frame.size.height+20, self.mainScrollView.frame.size.width-40, 40);
            self.customizationSelectionView.frame = CGRectMake(20, self.mainScrollView.frame.size.height-250, self.mainScrollView.frame.size.width-20, 250);
            break;
    }
    [super viewWillLayoutSubviews];
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
    
    self.descriptionlabel = [[UILabel alloc] init];
    self.descriptionlabel.numberOfLines = 0;
    self.descriptionlabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionlabel.text = self.welcomeDescriptionString;
    [self.mainScrollView addSubview:self.descriptionlabel];
    
    self.welcomeButton = [[UIButton alloc] init];
    [self.welcomeButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
    [self.welcomeButton setTitleColor:[UIColor purple400] forState:UIControlStateNormal];
    [self.welcomeButton addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainScrollView addSubview:self.welcomeButton];
}

- (void) setupCustomizationStep {
    self.justinView = [[UIImageView alloc] init];
    [self.justinView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/npc_justin.png"]];
    self.justinView.contentMode = UIViewContentModeCenter;
    [self.mainScrollView addSubview:self.justinView];
    
    self.avatarView = [[UIImageView alloc] init];
    [self.user setAvatarOnImageView:self.avatarView withPetMount:NO onlyHead:NO withBackground:NO useForce:NO];
    self.avatarView.contentMode = UIViewContentModeCenter;
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
            instructionString = NSLocalizedString(@"Choose a shirt!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'shirt'"];
            verticalCutoff = 1.1;
            selectedItem = self.user.shirt;
            break;
        case HRPGAvatarSetupStepsHairStyle:
            instructionString = NSLocalizedString(@"Choose a hairstyle!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'base'"];
            selectedItem = self.user.hairBase;
            verticalCutoff = 0.85;
            break;
        case HRPGAvatarSetupStepsHairColor:
            instructionString = NSLocalizedString(@"Choose a hair color!", nil);
            predicate = [NSPredicate predicateWithFormat:@"price == 0 && type == 'hair' && group == 'color'"];
            selectedItem = self.user.hairColor;
            verticalCutoff = 0.77;
            break;
    }
    
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.text = instructionString;
    [self.mainScrollView addSubview:self.instructionLabel];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Customization" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:predicate];
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
}

- (IBAction)nextStep:(id)sender {
    NSError *error;
    [self.managedObjectContext saveToPersistentStore:&error];
    if (self.currentStep != HRPGAvatarSetupStepsHairColor) {
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
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TaskSetupSegue"]) {
        HRPGTaskSetupTableViewController *destinationController = segue.destinationViewController;
        destinationController.user = self.user;
        destinationController.managedObjectContext = self.managedObjectContext;
        destinationController.currentStep = HRPGAvatarSetupStepsTasks;
    }
}

@end
