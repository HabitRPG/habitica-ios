//
//  HRPGLoadingViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGLoadingViewController.h"
#import "UIColor+Habitica.h"
#import <PDKeychainBindings.h>
#import "HRPGLoginViewController.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"
#import "User.h"
#import "HRPGAvatarSetupViewController.h"

@interface HRPGLoadingViewController ()
@end

@implementation HRPGLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    NSArray *colors = @[
                        @[@3,@1,@3,@3,@1,@3,@3,@3,@3,@3,@3,@3,@3,@3,@1,@3],
                        @[@3,@3,@3,@3,@3,@3,@3,@3,@3,@1,@3,@1,@3,@3,@3,@3],
                        @[@3,@2,@3,@1,@3,@2,@3,@1,@3,@2,@3,@2,@3,@2,@3,@2],
                        @[@2,@3,@2,@3,@2,@1,@2,@3,@2,@3,@2,@3,@2,@1,@2,@3],
                        @[@1,@2,@1,@2,@2,@2,@1,@2,@2,@2,@1,@2,@2,@2,@2,@2],
                        @[@2,@2,@2,@1,@1,@2,@2,@2,@2,@2,@2,@1,@2,@1,@1,@1],
                        @[@1,@2,@1,@1,@1,@1,@1,@2,@1,@2,@1,@1,@1,@2,@1,@2],
                        @[@2,@1,@1,@1,@2,@1,@1,@1,@2,@1,@1,@1,@2,@1,@1,@1],
                        @[@1,@1,@2,@1,@1,@1,@2,@1,@1,@1,@1,@1,@1,@1,@2,@1],
                        @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1,@2,@1,@1,@1,@1,@1]
                        ];
    
    self.view.backgroundColor = [UIColor clearColor];
    CGFloat squareSize = self.view.frame.size.width / 16;
    self.lineCount = ceil(self.view.frame.size.height / squareSize);
    CGFloat height = self.view.frame.size.height;
    
    self.squares = [NSMutableArray arrayWithCapacity:self.lineCount];
    for (int y = 1; y <= self.lineCount; y++) {
        NSMutableArray *line = [NSMutableArray arrayWithCapacity:16];
        for (int x = 0; x < 16; x++) {
            UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0+(squareSize*x), height-(squareSize*y), squareSize, squareSize)];
            if (colors.count >= y) {
                switch ([colors[y-1][x] integerValue]) {
                    case 1:
                        square.backgroundColor = [UIColor purple100];
                        break;
                    case 2:
                        square.backgroundColor = [UIColor purple200];
                        break;
                    case 3:
                        square.backgroundColor = [UIColor purple300];
                        break;
                    default:
                        square.backgroundColor = [UIColor purple100];
                        break;
                }
            } else {
                square.backgroundColor = [UIColor purple100];
            }
            [self.view addSubview:square];
            [line addObject:square];
        }
        [self.squares addObject:line];
    }
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_logo" ]];
    self.logo.frame = CGRectMake((self.view.frame.size.width-165)/2, 100, 165, 140);
    [self.view addSubview:self.logo];
    */
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    
    if ([keyChain stringForKey:@"id"] == nil || [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SetupSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoginSegue"]) {
        UINavigationController *navigationViewController = (UINavigationController*)segue.destinationViewController;
        HRPGLoginViewController *loginViewController = (HRPGLoginViewController*)navigationViewController.topViewController;
        loginViewController.isRootViewController = YES;
    } else if ([segue.identifier isEqualToString:@"SetupSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        HRPGAvatarSetupViewController *avatarSetupViewController = (HRPGAvatarSetupViewController*)navController.topViewController;
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        HRPGManager *manager = appdelegate.sharedManager;
        User *user = [manager getUser];
        avatarSetupViewController.lastCompletedStep = [user.lastSetupStep integerValue];
        avatarSetupViewController.user = user;
        avatarSetupViewController.managedObjectContext = manager.getManagedObjectContext;
    }
}

@end
