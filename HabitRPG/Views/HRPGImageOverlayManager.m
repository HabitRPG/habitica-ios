//
//  HRPGImageOverlayManager.m
//  Habitica
//
//  Created by viirus on 25/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGImageOverlayManager.h"
#import "HRPGImageOverlayView.h"

@interface HRPGImageOverlayManager ()

@property NSMutableArray *queue;
@property UIView *backgroundView;
@property BOOL displayingView;
@property HRPGImageOverlayView *activeView;
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
        self.queue = [NSMutableArray array];
        self.backgroundView = [[UIView alloc] init];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        self.backgroundView.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.backgroundView.userInteractionEnabled = NO;

    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

+ (void)displayImageWithString:(NSString *)image withText:(NSString *)text withNotes:(NSString *)notes {
    HRPGImageOverlayManager *manager = [HRPGImageOverlayManager sharedManager];
    [manager displayImageWithString:image withText:text withNotes:notes];
}

+ (void)displayImage:(UIImage *)image withText:(NSString *)text withNotes:(NSString *)notes {
    HRPGImageOverlayManager *manager = [HRPGImageOverlayManager sharedManager];
    [manager displayImage:image withText:text withNotes:notes];
}

- (void)displayImageWithString:(NSString *)image withText:(NSString *)text withNotes:(NSString *)notes {
    if (notes) {
        [self.queue addObject:@{@"image_name":image, @"text":text, @"notes":notes}];
    } else {
        [self.queue addObject:@{@"image_name":image, @"text":text}];
    }
    if (!self.displayingView) {
        [self displayNextImage];
    }
}

- (void)displayImage:(UIImage *)image withText:(NSString *)text withNotes:(NSString *)notes {
    if (notes) {
        [self.queue addObject:@{@"image":image, @"text":text, @"notes":notes}];
    } else {
        [self.queue addObject:@{@"image":image, @"text":text}];
    }
    if (!self.displayingView) {
        [self displayNextImage];
    }
}

- (void)displayNextImage {
    UITabBarController *mainTabbar = ((UITabBarController *) [[UIApplication sharedApplication] delegate].window.rootViewController);
    
    if (self.backgroundView && ![self.backgroundView isDescendantOfView:mainTabbar.view]) {
        [mainTabbar.view addSubview:self.backgroundView];
        
        [UIView animateWithDuration:0.3 animations:^() {
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        }];
    }
    NSDictionary *dict = [self.queue firstObject];
    [self.queue removeObjectAtIndex:0];
    self.activeView = [[HRPGImageOverlayView alloc] init];
    [self.activeView displayImageWithName:dict[@"image"]];
    
    self.activeView.width = 180;
    self.activeView.height = 120;
    if ([dict objectForKey:@"image_name"]) {
        [self.activeView displayImageWithName:dict[@"image_name"]];
    } else {
        [self.activeView displayImage:dict[@"image"]];
    }
    self.activeView.descriptionText = dict[@"text"];
    if ([dict objectForKey:@"notes"]) {
        self.activeView.detailText = dict[@"notes"];
    }
    
    __weak HRPGImageOverlayManager *weakSelf = self;
    self.activeView.dismissBlock = ^() {
        if (weakSelf.queue.count != 0) {
            [weakSelf displayNextImage];
        } else {
            weakSelf.displayingView = NO;
            weakSelf.activeView = nil;
            [UIView animateWithDuration:0.3 animations:^() {
                weakSelf.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            }completion:^(BOOL finished) {
                [weakSelf.backgroundView removeFromSuperview];
            }];
        }
    };
    
    [self.activeView display:^() {
    }];
    
}
@end
