//
//  HRPGCheckBoxView.h
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChecklistItem.h"
#import "HRPGTaskProtocol.h"

@interface HRPGCheckBoxView : UIView

@property(nonatomic) bool checked;
@property(nonatomic) BOOL isLocked;
@property(nonatomic) CGFloat size;
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic) UIColor *boxBorderColor;
@property(nonatomic) UIColor *boxFillColor;
@property(nonatomic) UIColor *checkColor;
@property(nonatomic) BOOL centerCheckbox;
@property(nonatomic) CGFloat padding;
@property(nonatomic) BOOL borderedBox;
 
- (void)configureForTask:(NSObject<HRPGTaskProtocol> *)task;
- (void)configureForTask:(NSObject<HRPGTaskProtocol> *)task withOffset:(NSInteger)offset;
- (void)configureForChecklistItem:(ChecklistItem *)item withTitle:(BOOL)withTitle;

@property(copy, nonatomic) void (^wasTouched)(void);

@end
