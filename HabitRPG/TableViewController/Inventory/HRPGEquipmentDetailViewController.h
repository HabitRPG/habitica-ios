//
//  HRPGEquipmentDetailViewController.h
//  Habitica
//
//  Created by Phillip on 08/08/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGEquipmentDetailViewController
    : HRPGBaseViewController<UIActionSheetDelegate>

@property NSString *type;
@property NSString *equipType;
@end
