//
//  HRPGSpellTabBarController.m
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGSpellTabBarController.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGSpellTabBarController ()
@end

@implementation HRPGSpellTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    int tabIndex = 0;
    for (SkillsTaskTableViewController *taskController in self.viewControllers) {
        switch (tabIndex) {
            case 0:
                taskController.taskTypeString = @"habit";
                break;
            case 1:
                taskController.taskTypeString = @"daily";
                break;
            case 2:
                taskController.taskTypeString = @"todo";
                break;
        }
        tabIndex++;
    }
}

- (void)castSpell {
    [self performSegueWithIdentifier:@"CastTaskSpellSegue" sender:self];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
