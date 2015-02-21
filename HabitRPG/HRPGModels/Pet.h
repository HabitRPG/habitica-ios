//
//  Pet.h
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pet : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSNumber * trained;
@property (nonatomic, retain) NSNumber * asMount;
@property (nonatomic, retain) NSString * type;
- (void)setMountOnImageView:(UIImageView *)imageView;
@end
