//
//  Preferences.m
//  Habitica
//
//  Created by Phillip Thelen on 17/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

// Insert code here to add functionality to your managed object subclass

- (NSString *)language {
    NSString *language = [self primitiveValueForKey:@"language"];
    if (!language) {
        language = @"en";
    }
    return language;
}

@end
