//
//  HRPGCustomizationSelectionView.h
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HRPGCustomizationSelectionView : UIView

@property (nonatomic) NSString *selectedItem;
@property (nonatomic) NSArray *items;
@property User *user;
@property CGFloat verticalCutoff;

@property (nonatomic, copy) void (^selectionAction)(Customization *selectedCustomization);

@end
