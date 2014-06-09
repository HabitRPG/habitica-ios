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

@interface HRPGHeaderTagView()
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property HRPGManager *sharedManager;
@property UILabel *label;
@end

@implementation HRPGHeaderTagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.921 alpha:1.000];
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        self.sharedManager = appdelegate.sharedManager;
        self.managedObjectContext = self.sharedManager.getManagedObjectContext;
        
        self.label = [[UILabel alloc] initWithFrame:self.frame];
        self.label.textColor = [UIColor colorWithRed:0.366 green:0.599 blue:0.014 alpha:1.000];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.label.text = NSLocalizedString(@"Filter by tags", nil);
        [self addSubview:self.label];
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"tagNavigationController"];
    HRPGTagViewController *tagController = (HRPGTagViewController *) navigationController.topViewController;
    tagController.selectedTags = [self.selectedTags mutableCopy];
    [self.currentNavigationController presentViewController:navigationController animated:YES completion:^() {
        
    }];
}

- (void)setSelectedTags:(NSArray *)selectedTags {
    _selectedTags = selectedTags;
    if (selectedTags && [selectedTags count] > 0) {
        NSMutableString *tagString = [NSMutableString stringWithString:@"Show Tags: "];
        for (Tag *tag in selectedTags) {
            [tagString appendFormat:@"%@, ", tag.name];
        }
        tagString = [tagString substringToIndex:tagString.length-2];
        self.label.text = tagString;
    } else {
        self.label.text = NSLocalizedString(@"Filter by tags", nil);
    }
}

@end
