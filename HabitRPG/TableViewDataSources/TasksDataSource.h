//
//  TasksDataSource.h
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HRPGTask;

@protocol TasksDataSourceDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface TasksDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<TasksDataSourceDelegate> delegate;
@property (nonatomic) NSArray<HRPGTask *> *tasks;
@property (nonatomic, weak) UITableView *tableView;
@end
