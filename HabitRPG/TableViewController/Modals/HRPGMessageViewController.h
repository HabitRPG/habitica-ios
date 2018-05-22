//
//  HRPGMessageViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 24/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface HRPGMessageViewController : UIViewController<UITextViewDelegate>

@property(weak, nonatomic) IBOutlet UITextView *messageView;

@property(nonatomic) NSString *presetText;
@end
