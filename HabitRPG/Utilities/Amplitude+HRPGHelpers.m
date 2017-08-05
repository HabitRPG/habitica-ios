//
//  Amplitude+HRPGHelpers.m
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import "Amplitude+HRPGHelpers.h"

@implementation Amplitude (HRPGHelpers)

- (void)logNavigateEventForClass:(NSString *)className {
    NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
    [eventProperties setValue:@"navigate" forKey:@"eventAction"];
    [eventProperties setValue:@"navigation" forKey:@"eventCategory"];
    [eventProperties setValue:@"pageview" forKey:@"hitType"];
    [eventProperties setValue:className forKey:@"page"];
    [self logEvent:@"navigate" withEventProperties:eventProperties];
}

@end
