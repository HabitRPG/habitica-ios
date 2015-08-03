//
//  HRPGWebViewController.m
//  Habitica
//
//  Created by viirus on 03.04.15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGWebViewController.h"
#import "HRPGTopHeaderNavigationController.h"

@interface HRPGWebViewController ()
@property BOOL shouldReshowTopHeader;
@end

@implementation HRPGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height,0,0,0)];
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height,0,0,0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    NSURL* nsUrl = [NSURL URLWithString:self.url];
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [self.webView loadRequest:request];
    
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        [navigationController toggleTopBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*)self.navigationController;
        [navigationController toggleTopBar];
    }
    
    [super viewWillDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

@end
