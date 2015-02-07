//
//  HRPGHeaderTagView.m
//  RabbitRPG
//
//  Created by Phillip on 08/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGHeaderTagView.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"
#import "HRPGTagViewController.h"
#import "Tag.h"
#import <NIKFontAwesomeIconFactory.h>
#import <NIKFontAwesomeIconFactory+iOS.h>
#import "HRPGNavigationController.h"

@interface HRPGHeaderTagView()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property HRPGManager *sharedManager;
@property UILabel *label;
@property UIImageView *tagIconView;
@property NIKFontAwesomeIconFactory *iconFactory;
@end

@implementation HRPGHeaderTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.000];
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        self.sharedManager = appdelegate.sharedManager;
        self.managedObjectContext = self.sharedManager.getManagedObjectContext;
        
        self.label = [[UILabel alloc] initWithFrame:self.frame];
        self.label.textColor = [UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:1.000];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.label.text = NSLocalizedString(@"Filter by tags", nil);
        [self addSubview:self.label];

        CALayer *bottomBorder = [CALayer layer];
        
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height-1, self.frame.size.width, 0.5f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.678 alpha:1.000].CGColor;
        [self.layer addSublayer:bottomBorder];
        
        self.iconFactory = [NIKFontAwesomeIconFactory tabBarItemIconFactory];
        self.iconFactory.square = YES;
        self.iconFactory.colors = @[[UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:0.700]];
        self.iconFactory.renderingMode = UIImageRenderingModeAlwaysOriginal;
        
        self.tagIconView = [[UIImageView alloc] init];
        self.tagIconView.contentMode = UIViewContentModeCenter;
        self.tagIconView.image = [self.iconFactory createImageForIcon:NIKFontAwesomeIconTags];
        [self addSubview:self.tagIconView];

        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
        [self layoutViews];
    }
    return self;
}

- (void)layoutViews {
    [self.label sizeToFit];
    if (self.label.frame.size.width > (self.frame.size.width-40)) {
        self.label.frame = CGRectMake(40, 0, self.frame.size.width-40, self.frame.size.height);
        self.tagIconView.frame = CGRectMake(0, 0, 40, self.frame.size.height);
    } else {
        
        self.label.frame = CGRectMake((self.frame.size.width/2)-(self.label.frame.size.width/2)+20, 0, self.label.frame.size.width, self.frame.size.height);
        self.tagIconView.frame = CGRectMake(self.label.frame.origin.x - 40, 0, 40, self.frame.size.height);
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    HRPGNavigationController *navigationController = (HRPGNavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"tagNavigationController"];
    navigationController.sourceViewController = self.currentNavigationController.topViewController;
    HRPGTagViewController *tagController = (HRPGTagViewController *) navigationController.topViewController;
    tagController.selectedTags = [self.selectedTags mutableCopy];
    [self.currentNavigationController presentViewController:navigationController animated:YES completion:^() {
        
    }];
}

- (void)setSelectedTags:(NSArray *)selectedTags {
    _selectedTags = selectedTags;
    if (selectedTags && [selectedTags count] > 0) {
        NSMutableString *tagString = [NSMutableString string];
        for (Tag *tag in selectedTags) {
            [tagString appendFormat:@"%@, ", tag.name];
        }
        self.label.text = [tagString substringToIndex:tagString.length-2];
        if ([selectedTags count] == 1) {
            self.tagIconView.image = [self.iconFactory createImageForIcon:NIKFontAwesomeIconTag];
        } else {
            self.tagIconView.image = [self.iconFactory createImageForIcon:NIKFontAwesomeIconTags];
        }
    } else {
        self.label.text = NSLocalizedString(@"Filter by tags", nil);
        self.tagIconView.image = [self.iconFactory createImageForIcon:NIKFontAwesomeIconTags];
    }
    [self layoutViews];
}

@end
