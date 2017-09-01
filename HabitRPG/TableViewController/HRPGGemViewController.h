//
//  HRPGGemViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 02/06/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"
#import "SeedsInAppMessageDelegate.h"

@interface HRPGGemViewController : UICollectionViewController <SeedsInAppMessageDelegate>

@property BOOL displayNoGemLabel;

@end
