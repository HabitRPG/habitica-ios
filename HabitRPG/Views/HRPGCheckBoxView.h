//
//  HRPGCheckBoxView.h
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "ChecklistItem.h"

@interface HRPGCheckBoxView : UIView

- (void)configureForTask:(Task *) task;
- (void)configureForTask:(Task *) task withOffset:(NSInteger) offset;
- (void)configureForChecklistItem:(ChecklistItem *) item forTask:(Task *)task;

@property (copy)void (^wasTouched)(void);

@end
