//
//  HRPGQRCodeView.m
//  Habitica
//
//  Created by Phillip Thelen on 05/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGQRCodeView.h"
#import "UIColor+Habitica.h"

@interface HRPGQRCodeView ()

@property UIImageView *qrCodeView;
@property UIView *avatarView;
@property UIView *wrapperView;
@property UIView *outerWrapperView;
@property int scaling;
@end

@implementation HRPGQRCodeView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.qrCodeView = [[UIImageView alloc] init];
    self.qrCodeView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.qrCodeView];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    return self;
}

- (void)layoutSubviews {
    self.qrCodeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self setQrCode];
    CGFloat avatarSize = 6 * 13;
    self.avatarView.frame = CGRectMake((self.qrCodeView.frame.size.width-avatarSize)/2, (self.qrCodeView.frame.size.height-avatarSize)/2, avatarSize, avatarSize);
    CGFloat innerSize = avatarSize-10;
    self.wrapperView.frame = CGRectMake(-41, -16, avatarSize*1.5, avatarSize*1.5);
    self.outerWrapperView.frame = CGRectMake(5, 5, innerSize, innerSize);
}

- (void)setUserID:(NSString *)userID {
    _userID = userID;
    [self setQrCode];
}

- (void)setAvatarViewWithUser:(User *)user {
    if (self.avatarView) {
        [self.avatarView removeFromSuperview];
    }
    self.avatarView = [[UIView alloc] init];
    self.avatarView.backgroundColor = [UIColor purple100];
    self.wrapperView = [[UIView alloc] init];
    self.outerWrapperView = [[UIView alloc] init];
    self.outerWrapperView.clipsToBounds = YES;
    self.outerWrapperView.backgroundColor = [UIColor whiteColor];
    [user setAvatarSubview:self.wrapperView showsBackground:NO showsMount:NO showsPet:NO];
    [self.outerWrapperView addSubview:self.wrapperView];
    [self.avatarView addSubview:self.outerWrapperView];
    [self addSubview:self.avatarView];
    [self layoutSubviews];
}

- (void)setQrCode {
    if (self.userID == nil) {
        return;
    }
    NSData *stringData = [[@"https://habitica.com/qr-code/user/" stringByAppendingString:self.userID] dataUsingEncoding:NSISOLatin1StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    self.qrCodeView.image = [self createNonInterpolatedUIImageFromCIImage:qrFilter.outputImage];
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image {
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    CGRect rect = CGRectMake(0, 0, 306, 306);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(cgImage),
                                        CGImageGetHeight(cgImage),
                                        CGImageGetBitsPerComponent(cgImage),
                                        CGImageGetBitsPerPixel(cgImage),
                                        CGImageGetBytesPerRow(cgImage),
                                        CGImageGetDataProvider(cgImage), NULL, false);
    CGContextClipToMask(context, rect, mask);
    CGColorRef color = [[UIColor purple100] CGColor];
    CGContextSetFillColorWithColor(context, color);
    CGContextFillRect(context, rect);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (self.shareAction) {
        self.shareAction();
    }
}

@end
