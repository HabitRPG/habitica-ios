//
//  HRPGNewsViewController.h
//  RabbitRPG
//
//  Created by viirus on 03/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRPGManager.h"

@interface HRPGNewsViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *newsWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property HRPGManager *sharedManager;

@end
