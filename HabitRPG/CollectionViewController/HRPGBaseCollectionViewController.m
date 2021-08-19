//
//  HRPGBBaseCollectionViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 13/07/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGBaseCollectionViewController.h"

@interface HRPGBaseCollectionViewController ()

@end

@implementation HRPGBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenWidth = screenRect.size.width;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.collectionView reloadData];
}

@end
