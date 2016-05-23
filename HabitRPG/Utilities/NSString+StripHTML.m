//
//  HRPG.m
//  Habitica
//
//  Created by Phillip Thelen on 23/05/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "NSString+StripHTML.h"

@implementation NSString (StripHTML)

-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end
