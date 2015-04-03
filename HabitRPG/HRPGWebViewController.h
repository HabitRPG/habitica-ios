//
//  HRPGWebViewController.h
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGWebViewController : UIViewController <UIWebViewDelegate>

@property NSString *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end
