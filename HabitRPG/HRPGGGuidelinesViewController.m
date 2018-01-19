//
//  HRPGGGuidelinesViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 18/05/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGGGuidelinesViewController.h"

@interface HRPGGGuidelinesViewController ()

@property UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation HRPGGGuidelinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [self.view viewWithTag:1];
    NSURL *nsUrl = [NSURL URLWithString:@"https://habitica.com/static/community-guidelines"];
    NSURLRequest *request =
        [NSURLRequest requestWithURL:nsUrl
                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                     timeoutInterval:30];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];

    if (self.needsAccepting) {
        [toolbarButtons removeObject:self.cancelButton];
        [toolbarButtons removeObject:self.acceptButton];
    } else {
        [toolbarButtons removeObject:self.doneButton];
    }
    [self.toolbar setItems:toolbarButtons animated:NO];
}

- (IBAction)dismissGuidelines:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
