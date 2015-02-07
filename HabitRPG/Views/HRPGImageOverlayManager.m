//
//  HRPGImageOverlayManager.m
//  RabbitRPG
//
//  Created by viirus on 25/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGImageOverlayManager.h"
#import "HRPGImageOverlayView.h"

@interface HRPGImageOverlayManager () {
    NSMutableArray *queue;
    UIView *backgroundView;
    HRPGImageOverlayView *activeView;
}

@end

@implementation HRPGImageOverlayManager

+ (id)sharedManager {
    static HRPGImageOverlayManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        queue = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

+ (void)displayImage:(NSString *)image withText:(NSString *)text withNotes:(NSString *)notes {
    HRPGImageOverlayManager *manager = [HRPGImageOverlayManager sharedManager];
    [manager displayImage:image withText:text withNotes:notes];
}

- (void)displayImage:(NSString *)image withText:(NSString *)text withNotes:(NSString *)notes {
    if (notes) {
        [queue addObject:@{@"image":image, @"text":text, @"notes":notes}];
    } else {
        [queue addObject:@{@"image":image, @"text":text}];
    }
    if (!activeView) {
        [self displayNextImage];
    }
}

- (void)displayNextImage {
    if (!backgroundView) {
        backgroundView = [[UIView alloc] init];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        backgroundView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        UITabBarController *mainTabbar = ((UITabBarController *) [[UIApplication sharedApplication] delegate].window.rootViewController);
        [mainTabbar.view addSubview:backgroundView];
        
        [UIView animateWithDuration:0.3 animations:^() {
            backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        }];
    }
    NSDictionary *dict = [queue firstObject];
    [queue removeObjectAtIndex:0];
    activeView = [[HRPGImageOverlayView alloc] init];
    [activeView displayImageWithName:dict[@"image"]];
    
    activeView.width = 180;
    activeView.height = 120;
    [activeView displayImageWithName:dict[@"image"]];
    activeView.descriptionText = dict[@"text"];
    if ([dict objectForKey:@"notes"]) {
    }
    
    __weak NSMutableArray *weakQueue = queue;
    __weak HRPGImageOverlayManager *weakSelf = self;
    __block HRPGImageOverlayView *weakActiveView = activeView;
    __block UIView *weakBackgroundView = backgroundView;
    activeView.dismissBlock = ^() {
        if (weakQueue.count != 0) {
            [weakSelf displayNextImage];
        } else {
            weakActiveView = nil;
            [UIView animateWithDuration:0.3 animations:^() {
                weakBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }completion:^(BOOL finished) {
                [weakBackgroundView removeFromSuperview];
                weakBackgroundView = nil;
            }];
        }
    };
    
    [activeView display:^() {
    }];
    
}
@end
