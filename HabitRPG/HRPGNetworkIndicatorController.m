//
//  HRPGNetworkIndicatorController.m
//  RabbitRPG
//
//  Created by Phillip Thelen on 15/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGNetworkIndicatorController.h"

@interface HRPGNetworkIndicatorController ()
@property NSInteger networkCount;
@end

@implementation HRPGNetworkIndicatorController

- (void)beginNetworking {
    if (self.networkCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    self.networkCount++;
}

- (void)endNetworking {
    self.networkCount--;
    if (self.networkCount == 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else if (self.networkCount < 0) {
        self.networkCount = 0;
    }
}

@end
