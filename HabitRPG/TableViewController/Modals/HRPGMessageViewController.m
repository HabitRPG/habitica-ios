//
//  HRPGMessageViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 24/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGMessageViewController.h"
#import "ChatMessage.h"
#import "User.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"

@interface HRPGMessageViewController ()
@property HRPGManager *sharedManager;

@end

@implementation HRPGMessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.sharedManager = appdelegate.sharedManager;
    self.managedObjectContext = self.sharedManager.getManagedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillHideNotification object:nil];
    
    [self keyboardChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.presetText) {
        self.messageView.text = self.presetText;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.messageView becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardChanged:(NSNotification *)notification{
    CGSize keyboardSize = [self.view convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:nil].size;
    CGFloat height = keyboardSize.height;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    self.messageView.frame = CGRectMake(4, 4, screenWidth-8, screenHeight-height-8);
}

-(void)textViewDidChange:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = ([textView.text length] > 0);
}

@end
