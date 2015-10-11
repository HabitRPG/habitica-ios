//
//  HRPGGearDetailView.m
//  Habitica
//
//  Created by Phillip Thelen on 20/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGGearDetailView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MetaReward.h"
#import "KLCPopup.h"
#import "UIColor+Habitica.h"
static inline UIImage* MTDContextCreateRoundedMask( CGRect rect, CGFloat radius_tl, CGFloat radius_tr, CGFloat radius_bl, CGFloat radius_br ) {
    
    CGContextRef context;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a bitmap graphics context the size of the image
    context = CGBitmapContextCreate( NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast );
    
    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);
    
    if ( context == NULL ) {
        return NULL;
    }
    
    // cerate mask
    
    CGFloat minx = CGRectGetMinX( rect ), midx = CGRectGetMidX( rect ), maxx = CGRectGetMaxX( rect );
    CGFloat miny = CGRectGetMinY( rect ), midy = CGRectGetMidY( rect ), maxy = CGRectGetMaxY( rect );
    
    CGContextBeginPath( context );
    CGContextSetGrayFillColor( context, 1.0, 0.0 );
    CGContextAddRect( context, rect );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    CGContextSetGrayFillColor( context, 1.0, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, minx, midy );
    CGContextAddArcToPoint( context, minx, miny, midx, miny, radius_bl );
    CGContextAddArcToPoint( context, maxx, miny, maxx, midy, radius_br );
    CGContextAddArcToPoint( context, maxx, maxy, midx, maxy, radius_tr );
    CGContextAddArcToPoint( context, minx, maxy, minx, midy, radius_tl );
    CGContextClosePath( context );
    CGContextDrawPath( context, kCGPathFill );
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef bitmapContext = CGBitmapContextCreateImage( context );
    CGContextRelease( context );
    
    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(bitmapContext);
    
    // return the image
    return theImage;
}  


@implementation HRPGGearDetailView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {

    }
    
    return self;
}

- (void)configureForReward:(MetaReward *)reward withGold:(CGFloat)gold {
    self.titleLabel.text = reward.text;
    self.priceLabel.text = [reward.value stringValue];
    if ([reward.key isEqualToString:@"potion"]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/shop_potion.png"]
                              placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else if ([reward.key isEqualToString:@"armoire"]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/shop_armoire.png"]
                              placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    } else if (![reward.key isEqualToString:@"reward"]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://habitica-assets.s3.amazonaws.com/mobileApp/images/shop_%@.png", reward.key]]
                              placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    }
    self.descriptionLabel.text = reward.notes;
    
    if ([reward.value floatValue] > gold) {
        self.buyButton.enabled = NO;
    } else {
        self.buyButton.enabled = YES;
    }
}

- (void)sizeToFit {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGFloat width = screenRect.size.width-80;
    
    if (width > 500) {
        width = 500;
    }
    
    self.frame = CGRectMake(0, 0, width, 300);
    [self layoutSubviews];
    //top margin, title-image margin, image, image-notes margin, notes-buttons margin, button height
    CGFloat height = 20+16+42+16+16+50;
    height = height + self.titleLabel.frame.size.height;
    
    height = height + [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(width-40, MAXFLOAT)
                                                                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                                          attributes:@{
                                                                                                       NSFontAttributeName : [UIFont systemFontOfSize:17]
                                                                                                       }
                                                                                             context:nil].size.height;
    
    self.frame = CGRectMake(0, 0, width, height);
    UIImage *mask = MTDContextCreateRoundedMask( self.bounds, 8.0, 8.0, 8.0, 8.0 );
    CALayer *layerMask = [CALayer layer];
    layerMask.frame = self.bounds;
    layerMask.contents = (id)mask.CGImage;
    self.layer.mask = layerMask;
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissPresentingPopup];
}

- (IBAction)buyButtonPressed:(id)sender {
    if (self.buyAction) {
        self.buyAction();
    }
    [self dismissPresentingPopup];
}

@end
