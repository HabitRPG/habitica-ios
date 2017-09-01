//
//  HRPGWebViewController.h
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGWebViewController : UIViewController<UIWebViewDelegate>

@property NSURL *url;
@property(weak, nonatomic) NSObject<UIWebViewDelegate> *webDelegate;
@property(weak, nonatomic) IBOutlet UIWebView *webView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end
