//
//  HRPGHabitTableViewController.m
//  HabitRPG
//
//  Created by Phillip Thelen on 08/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHabitTableViewController.h"
#import "Task.h"
#import "HRPGManager.h"
#import "MCSwipeTableViewCell.h"
#import <FontAwesomeIconFactory/NIKFontAwesomeIcon.h>
#import <FontAwesomeIconFactory/NIKFontAwesomeIconFactory+iOS.h>
#import "NSString+Emoji.h"

@interface HRPGHabitTableViewController ()
@property NSString *readableName;
@property NSString *typeName;
@property HRPGManager *sharedManager;
@property NIKFontAwesomeIconFactory *iconFactory;
@end

@implementation HRPGHabitTableViewController

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
    self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
    self.iconFactory.square = YES;
    self.iconFactory.colors = @[[UIColor whiteColor]];
    self.iconFactory.strokeColor = [UIColor whiteColor];
    self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
    self.readableName = NSLocalizedString(@"Habit", nil);
    self.typeName = @"habit";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)upDownSelected:(UISegmentedControl*)sender {
    UITableViewCell *cell = (UITableViewCell*)[[[sender superview] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Task *habit = (Task*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *direction;
    if (sender.selectedSegmentIndex == 0 && habit.down) {
            direction = @"down";
    } else {
        direction = @"up";
    }
    
    [self.sharedManager upDownTask:habit direction:direction onSuccess:^ () {
    } onError:^ () {
        [self.sharedManager displayNetworkError];
    }];
}

- (void)configureCell:(MCSwipeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withAnimation:(BOOL)animate
{
    Task *task = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIColor *color = [self.sharedManager getColorForValue:task.value];
    UILabel *label = (UILabel*)[cell viewWithTag:1];
    label.text = [task.text stringByReplacingEmojiCheatCodesWithUnicode];
    label.textColor = color;
    [self configureSwiping:cell withTask:task];
}

-(void)configureSwiping:(MCSwipeTableViewCell *)cell withTask:(Task*) task {
    if (self.tableView.editing) {
        cell.view3  = nil;
    }
    if (task.up) {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconPlus]];
        UIColor *greenColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
        [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"up" onSuccess:^(){
                
            }onError:^(){
                
            }];
        }];
    }
    if (task.down) {
        UIView *checkView = [self viewWithIcon:[self.iconFactory createImageForIcon:NIKFontAwesomeIconMinus]];
        UIColor *redColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        [cell setSwipeGestureWithView:checkView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self.sharedManager upDownTask:task direction:@"down" onSuccess:^(){
                
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
