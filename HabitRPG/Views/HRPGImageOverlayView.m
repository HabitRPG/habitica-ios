//
//  HRPGPetHatchedOverlayView.m
//  Habitica
//
//  Created by Phillip Thelen on 18/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGImageOverlayView.h"
#import <pop/POP.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface HRPGImageOverlayView ()
@property UILabel *label;
@property UILabel *detailLabel;
@property UIView *animationView;
@end

@implementation HRPGImageOverlayView

- (id)init {
    self.height = 140;
    self.width = 160;

    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    self = [super init];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor whiteColor];
        [self.layer setCornerRadius:5.0f];

        self.ImageView = [[UIImageView alloc]
            initWithFrame:CGRectMake(10, 10, self.width - 20, self.height - 30)];
        self.ImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.ImageView];

        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        [self addSubview:self.label];

        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
        self.detailLabel.numberOfLines = 0;
        [self addSubview:self.detailLabel];
    }
    return self;
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    self.frame = CGRectMake(0, 0, self.width, self.height);
    if (!self.descriptionText && !self.detailText) {
        self.ImageView.frame = CGRectMake(10, 10, self.width - 20, self.height - 30);
    }
}

- (void)setWidth:(CGFloat)width {
    _width = width;
    self.frame = CGRectMake(0, 0, self.width, self.height);
    self.ImageView.frame = CGRectMake(10, 10, self.width - 20, self.height - 30);
}

- (void)setDescriptionText:(NSString *)descriptionText {
    _descriptionText = descriptionText;
    self.label.text = descriptionText;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    NSInteger height = [descriptionText boundingRectWithSize:CGSizeMake(self.width - 20, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{
                                                      NSFontAttributeName : self.label.font
                                                  }
                                                     context:nil]
                           .size.height +
                       5;
    self.height = self.height + height;
    self.label.frame = CGRectMake(10, self.height - height - 10, self.width - 20, height);
    self.frame = CGRectMake(0, 0, self.width, self.height);
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    self.detailLabel.text = detailText;
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];

    NSInteger height = [detailText boundingRectWithSize:CGSizeMake(self.width - 20, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                 NSFontAttributeName : self.detailLabel.font
                                             }
                                                context:nil]
                           .size.height +
                       5;
    self.height = self.height + height;
    self.detailLabel.frame = CGRectMake(10, self.height - height - 10, self.width - 20, height);
    self.frame = CGRectMake(0, 0, self.width, self.height);
}

- (void)displayImageWithName:(NSString *)imageName {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager
        downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://"
                                                                             @"habitica-assets.s3."
                                                                             @"amazonaws.com/"
                                                                             @"mobileApp/images/%@",
                                                                             imageName]]
                     options:0
                    progress:nil
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,
                               BOOL finished, NSURL *imageURL) {
                       image = [UIImage imageWithCGImage:image.CGImage
                                                   scale:1.0
                                             orientation:UIImageOrientationUp];
                       if (image) {
                           self.ImageView.image = image;
                       }
                   }];
}

- (void)displayImage:(UIImage *)image {
    self.ImageView.image = image;
}

@end
