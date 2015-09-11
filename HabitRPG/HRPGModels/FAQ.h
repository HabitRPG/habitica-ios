//
//  FAQ.h
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FAQ : NSManagedObject

@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * iosAnswer;
@property (nonatomic, retain) NSString * webAnswer;
@property (nonatomic, retain) NSString * mobileAnswer;
@property (nonatomic, retain) NSNumber * index;

@end
