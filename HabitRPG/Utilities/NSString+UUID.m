//
//  NSString+UUID.m
//  Habitica
//
//  Created by Phillip Thelen on 11/08/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

-(BOOL)isValidUUID {
    NSUUID* UUID = [[NSUUID alloc] initWithUUIDString:self];
    if(UUID)
        return true;
    else
        return false;
}

@end
