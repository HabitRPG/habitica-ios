//
//  Pet.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <UIkit/UIKit.h>
#import "Food.h"

@interface Pet : NSManagedObject

@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) NSString *nicePetName;
@property(nonatomic, retain) NSString *niceMountName;
@property(nonatomic, retain) NSNumber *trained;
@property(nonatomic, retain) NSNumber *asMount;
@property(nonatomic, retain) NSString *type;
- (void)getMountImage:(void (^)(UIImage *))successBlock;
- (void)setMountOnImageView:(UIImageView *)imageView;
- (BOOL)likesFood:(Food *)food;
- (BOOL)isFeedable;

@end
