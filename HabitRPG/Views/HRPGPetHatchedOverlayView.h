//
//  HRPGPetHatchedOverlayView.h
//  RabbitRPG
//
//  Created by Phillip on 10/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGPetHatchedOverlayView : UIView

- (void)display:(void (^)())completitionBlock;

- (void)dismiss:(void (^)())completitionBlock;


@property (nonatomic, setter = setPetHatched:) NSString *hatchString;
@property UIImageView *petImageView;

@end
