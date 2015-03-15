//
//  HRPGPetHatchedOverlayView.h
//  Habitica
//
//  Created by Phillip on 10/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGImageOverlayView : UIView

- (void)display:(void (^)())completitionBlock;

- (void)dismiss:(void (^)())completitionBlock;

- (void)displayImageWithName:(NSString*)imageName;
- (void)displayImage:(UIImage*)image;

-(void)onDismiss:(void (^)())completitionBlock;

@property (copy)void (^dismissBlock)(void);

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

@property (nonatomic, setter = setDescriptionText:) NSString *descriptionText;
@property (nonatomic, setter = setDetailText:) NSString *detailText;

@property UIImageView *ImageView;

@end
