//
//  HRPGNewsViewController.h
//  Habitica
//
//  Created by viirus on 03/09/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGNewsViewController : UIViewController<UIWebViewDelegate>
@property(weak, nonatomic) IBOutlet UIWebView *newsWebView;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
