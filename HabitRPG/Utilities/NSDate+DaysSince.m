//
//  NSDate+DaysSince.m
//  Habitica
//
//  Created by Phillip Thelen on 11/04/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

@implementation NSDate (Screenshot)

- (NSNumber *)daysSinceDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];

    if (date == nil) {
        date = [NSDate date];
    }

    NSDate *fromDate;
    NSDate *toDate;

    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:date];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:self];

    NSDateComponents *difference =
        [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];

    return @([difference day]);
}

@end
