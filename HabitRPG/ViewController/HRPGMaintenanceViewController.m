//
//  HRPGMaintenanceViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 28/04/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGMaintenanceViewController.h"
#import "Masonry.h"
#import "UIViewController+Markdown.h"
#import "Habitica-Swift.h"

@interface HRPGMaintenanceViewController ()

@property UIScrollView *scrollView;
@property UIView *contentView;
@property UILabel *titleLabel;
@property UIImageView *imageView;
@property UITextView *descriptionTextView;
@property UIButton *appstoreButton;

@property CGFloat titleHeight;
@property CGFloat descriptionHeight;

@end

@implementation HRPGMaintenanceViewController

- (instancetype)init {
    self = [super init];

    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];

        self.scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:self.scrollView];

        self.contentView = [[UIView alloc] init];
        [self.scrollView addSubview:self.contentView];

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];

        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];

        self.descriptionTextView = [[UITextView alloc] init];
        self.descriptionTextView.scrollEnabled = NO;
        self.descriptionTextView.editable = NO;
        self.descriptionTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        [self.contentView addSubview:self.descriptionTextView];

        self.appstoreButton = [[UIButton alloc] init];
        [self.appstoreButton setTitle:objcL10n.openAppStore forState:UIControlStateNormal];
        [self.appstoreButton addTarget:self
                                action:@selector(appstoreButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
        [self.appstoreButton setTitleColor:ObjcThemeWrapper.tintColor forState:UIControlStateNormal];
        [self.contentView addSubview:self.appstoreButton];
    }

    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(20);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];

    int padding = 16;

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView).with.offset(padding);
        make.width.equalTo(self.scrollView).sizeOffset(CGSizeMake(-2 * padding, -padding));
        make.bottom.equalTo(self.appstoreButton.mas_bottom).with.offset(2 * padding);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(padding);
        make.left.mas_equalTo(@0);
        make.width.equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(self.titleHeight);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(padding);
        make.left.mas_equalTo(@0);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(@177);
    }];

    [self.descriptionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(padding);
        make.left.mas_equalTo(@0);
        make.width.equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(self.descriptionHeight);
    }];

    [self.appstoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionTextView.mas_bottom);
        make.left.mas_equalTo(@0);
        make.width.equalTo(self.contentView.mas_width);
        make.height.equalTo(@40);
    }];

    [super updateViewConstraints];
}

- (void)setMaintenanceData:(NSDictionary *)data {
    self.titleLabel.text = data[@"title"];
    self.titleHeight =
        [data[@"title"] boundingRectWithSize:CGSizeMake(self.view.frame.size.width, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{
                                      NSFontAttributeName :
                                          [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]
                                  }
                                     context:nil]
            .size.height;

    [ImageManager getImageWithUrl:data[@"imageUrl"] completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }
    }];

    NSAttributedString *descriptionText = [self renderMarkdown:data[@"description"]];

    self.descriptionTextView.attributedText = descriptionText;
    self.descriptionHeight =
        [self.descriptionTextView
            sizeThatFits:CGSizeMake(self.view.frame.size.width - 32, CGFLOAT_MAX)]
            .height;

    [self updateViewConstraints];
}

- (void)setIsDeprecatedApp:(BOOL)isDeprecatedApp {
    _isDeprecatedApp = isDeprecatedApp;
    self.appstoreButton.hidden = !isDeprecatedApp;
}

- (void)appstoreButtonPressed {
    NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id994882113?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink] options:@{} completionHandler:nil];
}

@end
