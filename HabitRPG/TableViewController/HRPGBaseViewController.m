//
//  HRPGBaseViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "HRPGManager.h"
#import "HRPGAppDelegate.h"
#import "HRPGRoundProgressView.h"
#import "HRPGDeathView.h"
#import "HRPGNavigationController.h"
#import "HRPGTopHeaderNavigationController.h"
#import <CoreText/CoreText.h>
#import <Google/Analytics.h>
#import "HRPGExplanationView.h"
#import "MPCoachMarks.h"
#import "TutorialSteps.h"
#import "UIViewController+TutorialSteps.h"

@interface HRPGBaseViewController ()
@property UIBarButtonItem *navigationButton;
@end

@implementation HRPGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[self getScreenName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
        [self.tableView setContentInset:UIEdgeInsetsMake([navigationController getContentInset],0,0,0)];
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentInset],0,0,0);
        if (navigationController.state == HRPGTopHeaderStateHidden) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentInset.top-[navigationController getContentOffset])];
        }
    }

    self.viewWidth = self.view.frame.size.width;
}

- (NSString *) getScreenName {
    if (self.readableScreenName) {
        return self.readableScreenName;
    } else {
        return NSStringFromClass([self class]);
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(void)viewWillLayoutSubviews {
    CGFloat newWidth = self.view.frame.size.width;
    if (self.viewWidth != newWidth) {
        self.viewWidth = newWidth;
        [self.tableView reloadData];
    }
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    if (self.refreshControl.isRefreshing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    }
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
        if (navigationController.state == HRPGTopHeaderStateHidden && self.tableView.contentOffset.y < self.tableView.contentInset.top-[navigationController getContentOffset]) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentInset.top-[navigationController getContentOffset])];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    User *user = [self.sharedManager getUser];
    if (user && [user.health floatValue] <= 0) {
        HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
        [deathView show];
    }
    
    [self displayTutorialStep:self.sharedManager];
    
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController *) self.navigationController;
        [navigationController startFollowingScrollView:self.tableView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController *) self.navigationController;
        [navigationController stopFollowingScrollView];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.displayedTutorialStep = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    //Skeletton method, so that it can be referenced from IB
}

- (IBAction)unwindToListSave:(UIStoryboardSegue *)segue {
    //Skeletton method, so that it can be referenced from IB
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *destViewController = segue.destinationViewController;
    if ([destViewController isKindOfClass:[HRPGNavigationController class]]) {
        HRPGNavigationController *destNavigationController = (HRPGNavigationController*)destViewController;
        destNavigationController.sourceViewController = self;
    }
}

- (NSDictionary *)markdownAttributes {
    static NSDictionary *_markdownAttributes = nil;
    if (!_markdownAttributes) {
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        CGFloat fontSize = font.pointSize;
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, fontSize, NULL);
        CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontBoldTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
        CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontItalicTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
        CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, (kCTFontBoldTrait | kCTFontItalicTrait), (kCTFontBoldTrait | kCTFontItalicTrait));
        // fix for cases in that font ref variants cannot be resolved - looking at you, HelveticaNeue!
        if (!boldItalicFontRef || !italicFontRef) {
            UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
            UIFont *italicFont = [UIFont italicSystemFontOfSize:fontSize];
            if (!boldFontRef) boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, fontSize, NULL);
            if (!italicFontRef) italicFontRef = CTFontCreateWithName((__bridge CFStringRef)italicFont.fontName, fontSize, NULL);
            if (!boldItalicFontRef) boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(italicFontRef, fontSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
        }
        CTFontRef h1FontRef = CTFontCreateCopyWithAttributes(boldFontRef, 24, NULL, NULL);
        CTFontRef h2FontRef = CTFontCreateCopyWithAttributes(boldFontRef, 20, NULL, NULL);
        CTFontRef h3FontRef = CTFontCreateCopyWithAttributes(boldFontRef, 16, NULL, NULL);
        NSDictionary *h1Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h1FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *h2Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h2FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *h3Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h3FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:(__bridge id)boldFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)italicFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *boldItalicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)boldItalicFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize-1], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
        NSDictionary *quoteAttributes = [NSDictionary dictionaryWithObjects:@[(id)[[UIColor grayColor] CGColor]] forKeys:@[(NSString *)kCTForegroundColorAttributeName]];
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.292 green:0.642 blue:0.013 alpha:1.000]};
        
        // release font refs
        CFRelease(fontRef);
        CFRelease(h1FontRef);
        CFRelease(h2FontRef);
        CFRelease(h3FontRef);
        CFRelease(boldFontRef);
        CFRelease(italicFontRef);
        CFRelease(boldItalicFontRef);
        // set the attributes
        _markdownAttributes = @{
                                @"GHFMarkdown_Headline1": h1Attributes,
                                @"GHFMarkdown_Headline2": h2Attributes,
                                @"GHFMarkdown_Headline3": h3Attributes,
                                @"GHFMarkdown_Headline4": boldAttributes,
                                @"GHFMarkdown_Headline5": boldAttributes,
                                @"GHFMarkdown_Headline6": boldAttributes,
                                @"GHFMarkdown_Bold": boldAttributes,
                                @"GHFMarkdown_Italic": italicAttributes,
                                @"GHFMarkdown_BoldItalic": boldItalicAttributes,
                                @"GHFMarkdown_CodeBlock": codeAttributes,
                                @"GHFMarkdown_CodeInline": codeAttributes,
                                @"GHFMarkdown_Quote": quoteAttributes,
                                @"GHFMarkdown_Link": linkAttributes};
    }
    return _markdownAttributes;
}

- (BOOL)isIndexPathVisible:(NSIndexPath *)indexPath {
        NSArray *indexes = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.item == indexPath.item && index.section == indexPath.section) {
                return YES;
            }
        }
        return NO;
}

- (HRPGManager *)sharedManager {
    if (_sharedManager == nil) {
        HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
        _sharedManager = appdelegate.sharedManager;
    }
    return _sharedManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        _managedObjectContext = self.sharedManager.getManagedObjectContext;
    }
    return _managedObjectContext;
}

@end
