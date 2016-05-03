//
//  HRPGNewsViewController.m
//  Habitica
//
//  Created by viirus on 03/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGNewsViewController.h"
#import "Amplitude.h"
#import "HRPGAppDelegate.h"

@interface HRPGNewsViewController ()

@end

@implementation HRPGNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;

    NSURLRequest *request = [NSURLRequest
        requestWithURL:[NSURL URLWithString:@"https://habitica.com/static/new-stuff"]];
    self.newsWebView.delegate = self;
    [self.newsWebView loadRequest:request];
    [self.loadingIndicator startAnimating];

    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:NSStringFromClass([self class]) forKey:@"page"];
    [[Amplitude instance] logEvent:@"navigate" withEventProperties:eventProperties];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIView animateWithDuration:0.4
                     animations:^() {
                         self.newsWebView.alpha = 1;
                         self.loadingIndicator.alpha = 0;
                     }];
    if ([[self.sharedManager getUser].flags.habitNewStuff boolValue]) {
        [self.sharedManager updateUser:@{
            @"flags.newStuff" : @NO
        }
            onSuccess:^() {
            }
            onError:^(){
            }];
    }
}

@end
