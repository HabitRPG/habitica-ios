//
//  HRPGFlagInformationOverlayView.m
//  Habitica
//
//  Created by Phillip Thelen on 11/02/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGFlagInformationOverlayView.h"
#import "KLCPopup.h"

static inline UIImage *MTDContextCreateRoundedMask(CGRect rect, CGFloat radius_tl,
                                                   CGFloat radius_tr, CGFloat radius_bl,
                                                   CGFloat radius_br) {
    CGContextRef context;
    CGColorSpaceRef colorSpace;

    colorSpace = CGColorSpaceCreateDeviceRGB();

    // create a bitmap graphics context the size of the image
    context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace,
                                    kCGImageAlphaPremultipliedLast);

    // free the rgb colorspace
    CGColorSpaceRelease(colorSpace);

    if (context == NULL) {
        return NULL;
    }

    // cerate mask

    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);

    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 1.0, 0.0);
    CGContextAddRect(context, rect);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);

    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius_bl);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius_br);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius_tr);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius_tl);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);

    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    // convert the finished resized image to a UIImage
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(bitmapContext);

    // return the image
    return theImage;
}

@implementation HRPGFlagInformationOverlayView

- (void)setUsername:(NSString *)username {
    NSString *titleString =
        [NSString stringWithFormat:NSLocalizedString(@"Report %@ for violation?", nil), username];
    NSMutableAttributedString *title =
        [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:[NSString stringWithFormat:@"(%@)", username]
                             options:kNilOptions
                               error:nil];

    NSRange range = NSMakeRange(0, titleString.length);

    [regex enumerateMatchesInString:titleString
                            options:kNilOptions
                              range:range
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags,
                                      BOOL *stop) {

                             NSRange subStringRange = [result rangeAtIndex:1];
                             [title addAttribute:NSForegroundColorAttributeName
                                           value:[UIColor redColor]
                                           range:subStringRange];
                         }];
    self.titleLabel.attributedText = title;
}

- (void)setMessage:(NSString *)message {
    self.messageTextView.text = message;
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissPresentingPopup];
}

- (IBAction)flagButtonTapped:(id)sender {
    if (self.flagAction) {
        self.flagAction();
    }
}

- (void)sizeToFit {
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    CGFloat width = screenRect.size.width - 40;

    if (width > 500) {
        width = 500;
    }

    [self setFrame:CGRectMake(0, 0, width, 300)];
    // top margin, title-message margin, message-explanation margin, explanation-buttons margin,
    // button height
    CGFloat height = 20 + 12 + 12 + 8 + 30 + 40;
    height = height +
             [self.titleLabel.text boundingRectWithSize:CGSizeMake(width - 70, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin |
                                                        NSStringDrawingUsesFontLeading
                                             attributes:@{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:17]
                                             }
                                                context:nil]
                 .size.height;
    height = height +
             [self.explanationTextView.text
                 boundingRectWithSize:CGSizeMake(width - 70, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin |
                                      NSStringDrawingUsesFontLeading
                           attributes:@{
                               NSFontAttributeName : [UIFont systemFontOfSize:14]
                           }
                              context:nil]
                 .size.height;

    height =
        height +
        [self.messageTextView.text boundingRectWithSize:CGSizeMake(width - 70, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin |
                                                        NSStringDrawingUsesFontLeading
                                             attributes:@{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:14]
                                             }
                                                context:nil]
            .size.height;

    if (height > screenRect.size.height - 60) {
        height = screenRect.size.height - 60;
    }

    self.frame = CGRectMake(0, 0, width, height);
    UIImage *mask = MTDContextCreateRoundedMask(self.bounds, 8.0, 8.0, 8.0, 8.0);
    CALayer *layerMask = [CALayer layer];
    layerMask.frame = self.bounds;
    layerMask.contents = (id)mask.CGImage;
    self.layer.mask = layerMask;
}

@end
