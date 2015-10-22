//
//  HRPGBatchOperation.h
//  Habitica
//
//  Created by Phillip Thelen on 22/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGBatchOperation : NSObject

@property NSString *op;
@property NSDictionary *body;

@end
