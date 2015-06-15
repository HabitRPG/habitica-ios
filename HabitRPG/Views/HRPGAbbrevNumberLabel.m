//
//  HRPGApprevNumberLabel.m
//  Habitica
//
//  Created by Phillip Thelen on 15/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGAbbrevNumberLabel.h"

@implementation HRPGAbbrevNumberLabel

- (void)setText:(NSString *)text {
    double value = [text doubleValue];
    int counter = 0;
    while (value > 1000) {
        counter++;
        value = value / 1000;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.roundingIncrement = [NSNumber numberWithDouble:0.01];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    text = [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:[NSNumber numberWithDouble:value]], [self abbreviationForCounter:counter]];
    super.text = text;
}

- (NSString*)abbreviationForCounter:(int)counter {
    switch (counter) {
        case 1:
            return @"k";
            break;
        case 2:
            return @"m";
            break;
        case 3:
            return @"b";
            break;
        case 4:
            return @"t";
            break;
            
        default:
            return @"";
            break;
    }
}

@end
