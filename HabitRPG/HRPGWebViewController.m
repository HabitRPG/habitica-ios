//
//  HRPGWebViewController.m
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGWebViewController.h"

@interface HRPGWebViewController ()
@property BOOL shouldReshowTopHeader;
@end

@implementation HRPGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.webDelegate) {
        self.webView.delegate = self.webDelegate;
    }

    [self.webView.scrollView
        setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height,
                                         0, 0, 0)];
    self.webView.scrollView.scrollIndicatorInsets =
        UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSURLRequest *request =
        [NSURLRequest requestWithURL:self.url
                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                     timeoutInterval:30];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
}

@end
