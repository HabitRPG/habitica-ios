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

@property(nonatomic) CGFloat imageHeight;
@property(nonatomic) CGFloat imageWidth;

@property(nonatomic) NSString *titleText;
@property(nonatomic) NSString *descriptionText;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) NSString *dismissButtonText;
@property (nonatomic) void (^shareAction)();

@end
