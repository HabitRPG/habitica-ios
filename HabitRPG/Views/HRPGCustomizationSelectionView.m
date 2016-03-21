//
//  HRPGCustomizationSelectionView.m
//  Habitica
//
//  Created by Phillip Thelen on 30/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGCustomizationSelectionView.h"
#import "Customization.h"
#import <YYWebImage.h>
#import "UIColor+Habitica.h"

@interface HRPGCustomizationSelectionView ()

@property(nonatomic) NSArray *views;
@property(nonatomic) UIView *selectedView;
@end

@implementation HRPGCustomizationSelectionView

CGFloat space = 10;
CGFloat viewSize = 60;

- (instancetype)init {
    self = [super init];

    if (self) {
    }

    return self;
}

- (void)layoutSubviews {
    NSInteger perRowCount = self.frame.size.width / (viewSize + space);
    CGFloat alignedSpace = (self.frame.size.width / perRowCount) - viewSize;
    CGFloat xOffset =
        (self.frame.size.width - (perRowCount * viewSize + (perRowCount - 1) * alignedSpace)) / 2;
    NSInteger count = 0;
    for (UIImageView *view in self.views) {
        NSInteger yOffset = 0;
        NSInteger column = count;
        NSInteger row = 0;
        CGFloat thisXOffset = xOffset;
        if (count >= perRowCount) {
            row = count / perRowCount;

            column = count - (row * perRowCount);
            yOffset = (viewSize + space) * row;
        }
        if ((NSInteger)(self.views.count - ((row + 1) * perRowCount)) < 0) {
            NSInteger inThisRow = self.views.count - ((row)*perRowCount);
            thisXOffset =
                (self.frame.size.width - (inThisRow * viewSize + (inThisRow - 1) * alignedSpace)) /
                2;
        }

        view.frame = CGRectMake(thisXOffset + column * (viewSize + alignedSpace),
                                row * (viewSize + alignedSpace), viewSize, viewSize);
        count++;
    }
    if (self.selectedItem) {
        count = 0;
        for (Customization *item in self.items) {
            if ([item.name isEqualToString:self.selectedItem]) {
                self.selectedView.frame = ((UIView *)self.views[count]).frame;
                self.selectedView.layer.cornerRadius = viewSize / 2;
                break;
            }
            count++;
        }
    }
}

- (void)sizeToFit {
    if (self.views.count > 0) {
        UIView *lastview = self.views[self.views.count - 1];
        CGRect frame = self.frame;
        frame.size.height = lastview.frame.size.height + lastview.frame.origin.y;
        self.frame = frame;
    }
}

- (void)setItems:(NSArray *)items {
    _items = items;

    if (self.views) {
        for (UIView *view in self.views) {
            [view removeFromSuperview];
        }
    }

    NSMutableArray *viewArray = [NSMutableArray arrayWithCapacity:items.count];
    NSInteger count = 0;
    for (Customization *item in items) {
        UIImageView *view = [[UIImageView alloc] init];
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        [manager
            requestImageWithURL:
                [NSURL
                    URLWithString:[NSString stringWithFormat:@"https://"
                                                             @"habitica-assets.s3.amazonaws.com/"
                                                             @"mobileApp/images/%@.png",
                                                             [item getImageNameForUser:self.user]]]
                        options:0
                       progress:nil
         transform:^UIImage *_Nullable(UIImage *_Nonnull image, NSURL *_Nonnull url) {
             return [YYImage imageWithData:[image yy_imageDataRepresentation] scale:1.0];
         }
                     completion:^(UIImage *_Nullable image, NSURL *_Nonnull url,
                                  YYWebImageFromType from, YYWebImageStage stage,
                                  NSError *_Nullable error) {
                         if (image) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 view.image = image;
                             });
                         }

                     }];
        view.contentMode = UIViewContentModeBottomRight;
        view.layer.contentsRect = CGRectMake(0, 0, 0.96, self.verticalCutoff);
        view.tag = count;
        [self addSubview:view];

        UITapGestureRecognizer *tapRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemSelected:)];
        tapRecognizer.numberOfTapsRequired = 1;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tapRecognizer];

        [viewArray addObject:view];
        count++;
    }

    self.views = viewArray;
}

- (void)setSelectedItem:(NSString *)selectedItem {
    _selectedItem = selectedItem;

    if (!self.selectedView) {
        self.selectedView = [[UIView alloc] init];
        self.selectedView.backgroundColor = [UIColor purple400];
        [self addSubview:self.selectedView];
    }

    [self setNeedsLayout];
}

- (void)itemSelected:(UITapGestureRecognizer *)recognizer {
    self.selectionAction(self.items[recognizer.view.tag]);
    self.selectedItem = ((Customization *)self.items[recognizer.view.tag]).name;
    [UIView animateWithDuration:0.3
        delay:0.0
        usingSpringWithDamping:0.8
        initialSpringVelocity:0.5
        options:UIViewAnimationOptionCurveLinear
        animations:^() {
            self.selectedView.frame = ((UIView *)self.views[recognizer.view.tag]).frame;
        }
        completion:^(BOOL completed){

        }];
}

@end
