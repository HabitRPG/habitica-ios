//
//  NSDAte+NSDateMock.h
//  Habitica
//
//  Created by Phillip Thelen on 16/06/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateMock)

+(void)setMockDate:(NSString *)mockDate;
+(NSDate *) mockCurrentDate;

@end