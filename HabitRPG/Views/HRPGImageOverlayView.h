//
//  HRPGPetHatchedOverlayView.h
//  Habitica
//
//  Created by Phillip on 10/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLCPopup.h"

@interface HRPGImageOverlayView : UIView<UIGestureRecognizerDelegate>

- (void)displayImageWithName:(NSString *)imageName;
- (void)displayImage:(UIImage *)image;

@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat width;

@property(nonatomic, setter=setDescriptionText:) NSString *descriptionText;
@property(nonatomic, setter=setDetailText:) NSString *detailText;

@property UIImageView *ImageView;

@end
