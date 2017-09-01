//
//  HRPGSharingManager.h
//  Habitica
//
//  Created by Phillip Thelen on 25/04/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGSharingManager : NSObject

+ (void)shareItems:(NSArray *)items
    withPresentingViewController:(UIViewController *)presentingViewController
    withSourceView:(UIView *)sourceView;

@end
