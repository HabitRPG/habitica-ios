//
//  HRPGCoachmarkFrameProvider.h
//  Habitica
//
//  Created by Elliot Schrock on 6/29/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGCoachmarkFrameProvider : NSObject
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) UINavigationItem *navigationItem;
@property (nonatomic, weak) UIViewController *parentViewController;

- (NSDictionary *)getDefinitonForTutorial:(NSString *)tutorialIdentifier;
- (CGRect)getFrameForCoachmark:(NSString *)coachMarkIdentifier;
@end
