//
//  HRPGPetHatchedOverlayView.h
//  RabbitRPG
//
//  Created by Phillip on 10/07/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGImageOverlayView : UIView

- (void)display:(void (^)())completitionBlock;

- (void)dismiss:(void (^)())completitionBlock;

- (void)displayImageWithName:(NSString*)imageName;

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

@property (nonatomic, setter = setDescriptionText:) NSString *descriptionText;
@property (nonatomic, setter = setDetailText:) NSString *detailText;

@property UIImageView *ImageView;

@end
