//
//  HRPGPurchaseButtom.m
//  Habitica
//
//  Created by Phillip Thelen on 17/05/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGPurchaseButton.h"

@implementation HRPGPurchaseButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        self.layer.cornerRadius = 5.0f;
    }

    return self;
}

@end
