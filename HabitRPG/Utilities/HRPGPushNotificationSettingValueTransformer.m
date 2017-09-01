//
//  HRPGPushNotificationSettingValueTransformer.m
//  Habitica
//
//  Created by Phillip Thelen on 24/06/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGPushNotificationSettingValueTransformer.h"
#import "XLForm.h"

@implementation HRPGPushNotificationSettingValueTransformer

-(id)transformedValue:(id)value {
    if ([[value class] isSubclassOfClass:[NSArray class]]) {
        return @"";
    } else if ([value class] == [XLFormOptionsObject class]) {
        return ((XLFormOptionsObject *)value).formDisplayText;
    }
    return value;
}

@end
