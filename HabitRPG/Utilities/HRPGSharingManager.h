//
//  HRPGSharingManager.h
//  Habitica
//
//  Created by Phillip Thelen on 25/04/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGSharingManager : NSObject

+ (void)shareItems:(NSArray * _Nonnull)items
    withPresentingViewController:(UIViewController * _Nonnull)presentingViewController
    withSourceView:(UIView * _Nullable)sourceView;

@end
