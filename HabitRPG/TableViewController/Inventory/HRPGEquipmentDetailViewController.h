//
//  HRPGEquipmentDetailViewController.h
//  Habitica
//
//  Created by Phillip on 08/08/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGBaseViewController.h"

@interface HRPGEquipmentDetailViewController
    : HRPGBaseViewController<UIActionSheetDelegate>

@property NSString *type;
@property NSString *equipType;
@end
