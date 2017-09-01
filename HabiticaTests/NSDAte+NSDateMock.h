//
//  NSDAte+NSDateMock.h
//  Habitica
//
//  Created by Phillip Thelen on 16/06/15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateMock)

+(void)setMockDate:(NSString *)mockDate;
+(NSDate *) mockCurrentDate;

@end
