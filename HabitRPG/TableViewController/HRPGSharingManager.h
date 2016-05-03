//
//  HRPGSharingManager.h
//  Habitica
//
//  Created by Phillip Thelen on 25/04/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGSharingManager : NSObject

+ (void)shareItems:(NSArray *)items
    withPresentingViewController:(UIViewController *)presentingViewController;

@end
