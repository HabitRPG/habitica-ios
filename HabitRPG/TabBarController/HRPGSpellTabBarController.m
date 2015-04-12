//
//  HRPGSpellTabBarController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGSpellTabBarController.h"
#import "HRPGSpellTaskController.h"
#import "HRPGAppDelegate.h"
#import <NIKFontawesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>

@interface HRPGSpellTabBarController ()
@property HRPGManager *sharedManager;
@end

@implementation HRPGSpellTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;

    NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];

    UITabBarItem *item0 = self.tabBar.items[0];
    item0.image = [factory createImageForIcon:NIKFontAwesomeIconArrowsV];

    UIImage *calendarImage = [factory createImageForIcon:NIKFontAwesomeIconCalendarO];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(calendarImage.size.width, calendarImage.size.height), NO, 0.0f);
    [calendarImage drawInRect:CGRectMake(0, 0, calendarImage.size.width, calendarImage.size.height)];
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

    [self.tabBar setTintColor:[UIColor colorWithRed:0.837 green:0.652 blue:0.238 alpha:1.000]];

    int tabIndex = 0;
    for (HRPGSpellTaskController *taskController in self.viewControllers) {
        switch (tabIndex) {
            case 0:
                taskController.taskType = @"habit";
                break;
            case 1:
                taskController.taskType = @"daily";
                break;
            case 2:
                taskController.taskType = @"todo";
                break;
        }
        tabIndex++;
    }
}


- (void)castSpell {
    [self.sharedManager castSpell:self.spell.key withTargetType:self.spell.target onTarget:self.taskID onSuccess:^() {
        [self.sourceTableView reloadData];
    }                     onError:^() {

    }];
    [self dismissViewControllerAnimated:YES completion:^() {

    }];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {

    }];
}

@end
