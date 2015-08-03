//
//  HRPGBaseViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 29/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "HRPGManager.h"
#import <PDKeychainBindings.h>
#import "HRPGAppDelegate.h"
#import "HRPGRoundProgressView.h"
#import "HRPGActivityIndicator.h"
#import "HRPGDeathView.h"
#import "HRPGNavigationController.h"
#import "HRPGTopHeaderNavigationController.h"
#import <CoreText/CoreText.h>
#import "HRPGActivityIndicatorOverlayView.h"
#import <Google/Analytics.h>

@interface HRPGBaseViewController ()
@property UIBarButtonItem *navigationButton;
@property HRPGActivityIndicator *activityIndicator;
@end

@implementation HRPGBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:[self getScreenName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];

    if ([keyChain stringForKey:@"id"] == nil || [[keyChain stringForKey:@"id"] isEqualToString:@""]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        UINavigationController *navigationController = (UINavigationController *) [storyboard instantiateViewControllerWithIdentifier:@"loginNavigationController"];
        [self presentViewController:navigationController animated:NO completion:nil];
    }
    
    if (!self.hidesTopBar && [self.navigationController isKindOfClass:[HRPGTopHeaderNavigationController class]]) {
        HRPGTopHeaderNavigationController *navigationController = (HRPGTopHeaderNavigationController*) self.navigationController;
        [self.tableView setContentInset:UIEdgeInsetsMake([navigationController getContentOffset],0,0,0)];
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake([navigationController getContentOffset],0,0,0);
    }

    self.activityCounter = 0;
    
    [self orientationChanged:nil];  // orientationChanged sets the screenWidth based on the orientation of the user interface
}

- (NSString *) getScreenName {
    if (self.readableScreenName) {
        return self.readableScreenName;
    } else {
        return NSStringFromClass([self class]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredContentSizeChanged:)
     name:UIContentSizeCategoryDidChangeNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
    
    if (self.refreshControl.isRefreshing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl beginRefreshing];
            [self.refreshControl endRefreshing];
        });
    }
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
    
    if (self.activityCounter > 0) {
        [self.activityIndicator animate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    User *user = [self.sharedManager getUser];
    if (user && [user.health floatValue] <= 0) {
        HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
        [deathView show];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.activityIndicator pauseAnimating];
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)orientationChanged:(NSNotification *)notification {
    // just because the orientation of the device changed does not mean the orientation of the User Interface changed.  Determine the Orientation of the User Interface and then set the self.screenWidth value accordingly

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            // if the User Interface is in Portrait mode then self.screenWidth = the device width
        self.screenWidth = screenRect.size.width;
    } else if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            // if the User Interface is in Landscape mode then self.screenWidth = the device height
        self.screenWidth = screenRect.size.height;
    }
        // now that self.screenWidth has been set, reload the data
    [self.tableView reloadData];
}


-(void)addActivityCounter {
    if (self.activityCounter == 0) {
        self.navigationButton = self.navigationItem.rightBarButtonItem;
        self.activityIndicator = [[HRPGActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.activityIndicator setInnerInset:3];
        UIBarButtonItem *indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
        [self.navigationItem setRightBarButtonItem:indicatorButton animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.activityIndicator beginAnimating];
        });
    }
    self.activityCounter++;
}

- (void)removeActivityCounter {
    self.activityCounter--;
    if (self.activityCounter == 0) {
        [self.activityIndicator endAnimating:^() {
            [self.activityIndicator endAnimating:^() {
                [self.navigationItem setRightBarButtonItem:self.navigationButton animated:NO];
            }];
        }];
    } else if (self.activityCounter < 0) {
        self.activityCounter = 0;
    }
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
