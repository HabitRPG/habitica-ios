//
//  Item.m
//  HabitRPG
//
//  Created by Phillip Thelen on 23/04/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Item.h"

@implementation Item

@dynamic key;
@dynamic text;
@dynamic notes;
@dynamic owned;
@dynamic value;
@dynamic dialog;
@dynamic type;
@dynamic isSubscriberItem;

- (void)setType:(NSString *)type {
    [self willChangeValueForKey:@"type"];
    [self setPrimitiveValue:[type stringByReplacingOccurrencesOfString:@"data." withString:@""]
                     forKey:@"type"];
    [self didChangeValueForKey:@"type"];
}

@end
