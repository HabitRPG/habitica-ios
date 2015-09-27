//
//  HRPGFAQDetailTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 07/09/15.
//  Copyright (c) 2015 Phillip Thelen. All rights reserved.
//

#import "HRPGFAQDetailViewController.h"
#import <CoreText/CoreText.h>
#import "NSMutableAttributedString_GHFMarkdown.h"

@interface HRPGFAQDetailViewController ()

@end

@implementation HRPGFAQDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.questionLabel.text = self.faq.question;
    
    NSMutableAttributedString *attributedText = [NSMutableAttributedString ghf_mutableAttributedStringFromGHFMarkdown:[self.faq getRelevantAnswer]];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [attributedText addAttribute:NSFontAttributeName value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] range:NSMakeRange(0, attributedText.length)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, attributedText.length)];
    [attributedText ghf_applyAttributes:self.markdownAttributes];

    
    self.answerTextView.attributedText = attributedText;
    self.answerTextView.textContainerInset = UIEdgeInsetsMake(0, 16, 16, 16);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.answerTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
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


@end
