//
//  HRPGDailyTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGDailyTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"
#import "MCSwipeTableViewCell.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>

@interface HRPGDailyTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property NIKFontAwesomeIconFactory *iconFactory;
@end

@implementation HRPGDailyTableViewController

@dynamic readableName;
@dynamic typeName;
@dynamic sharedManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.iconFactory = [NIKFontAwesomeIconFactory buttonIconFactory];
    self.readableName = NSLocalizedString(@"Daily", nil);
    self.typeName = @"daily";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = task.text;
    
    if (task.completed) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        label.textColor = [UIColor grayColor];
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconSquareO]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(){
                
            }onError:^(){
                
            }];
        }];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        label.textColor = [self.sharedManager getColorForValue:task.value];
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconCheckSquareO]];
        UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(){
                
            }onError:^(){
                
            }];
        }];
    }
}
- (UIView *)viewWithIcon:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

@end
