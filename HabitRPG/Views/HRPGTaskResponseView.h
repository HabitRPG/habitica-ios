//
//  HRPGTaskResponseView.h
//  Habitica
//
//  Created by Phillip on 03/08/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGTaskResponseView : UIView

- (void) show;
- (void) hide;
- (void) dismiss:(void (^)())completed;
- (void) dismisswithDelay:(float)delay completed:(void (^)())completed;
- (void) shouldDismissWithDelay:(float)delay;

- (void) addExpAndGoldViews;
- (void) updateWithValues:(NSArray*)valuesArray;

@property NSNumber *health;
@property NSNumber *healthMax;
@property NSNumber *experience;
@property NSNumber *experienceMax;
@property NSNumber *gold;

@property BOOL isDisplaying;
@property BOOL isVisible;
@property BOOL wasTapped;
@end
