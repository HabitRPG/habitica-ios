//
//  HRPGTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 04/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "UIViewController+Markdown.h"
#import "UIColor+Habitica.h"
#import "markdown_lib.h"
#import "markdown_peg.h"

@implementation UIViewController (Markdown)

@dynamic attributes;

- (void)configureMarkdownAttributes {
    self.attributes = [[NSMutableDictionary alloc] init];

    UIFont *plainFont = [UIFont systemFontOfSize:14.0f];
    NSDictionary *plainAttributes = @{
        NSFontAttributeName : plainFont,
    };

    self.attributes[@(PLAIN)] = plainAttributes;

    // p

    UIFont *paragraphFont = [UIFont systemFontOfSize:14.0f];
    NSMutableParagraphStyle *pParagraphStyle = [[NSMutableParagraphStyle alloc] init];

    pParagraphStyle.paragraphSpacing = 4;
    pParagraphStyle.paragraphSpacingBefore = 4;
    NSDictionary *pAttributes = @{
        NSFontAttributeName : paragraphFont,
        NSParagraphStyleAttributeName : pParagraphStyle,
    };

    self.attributes[@(PARA)] = pAttributes;

    // h1
    UIFont *h1Font = [UIFont boldSystemFontOfSize:24.0f];
    self.attributes[@(H1)] = @{NSFontAttributeName : h1Font};

    // h2
    UIFont *h2Font = [UIFont boldSystemFontOfSize:18.0f];
    self.attributes[@(H2)] = @{NSFontAttributeName : h2Font};

    // h3
    UIFont *h3Font = [UIFont boldSystemFontOfSize:17.0f];
    self.attributes[@(H3)] = @{NSFontAttributeName : h3Font};

    // em
    UIFont *emFont = [UIFont italicSystemFontOfSize:14.0f];
    self.attributes[@(EMPH)] = @{NSFontAttributeName : emFont};

    // strong
    UIFont *strongFont = [UIFont boldSystemFontOfSize:14.0f];
    self.attributes[@(STRONG)] = @{NSFontAttributeName : strongFont};

    // ul
    NSMutableParagraphStyle *listParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    listParagraphStyle.headIndent = 16.0;
    self.attributes[@(BULLETLIST)] =
        @{NSFontAttributeName : paragraphFont, NSParagraphStyleAttributeName : listParagraphStyle};

    // li
    NSMutableParagraphStyle *listItemParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    listItemParagraphStyle.headIndent = 16.0;
    self.attributes[@(LISTITEM)] = @{
        NSFontAttributeName : paragraphFont,
        NSParagraphStyleAttributeName : listItemParagraphStyle
    };

    // a
    UIColor *linkColor = [UIColor purple400];
    self.attributes[@(LINK)] = @{NSForegroundColorAttributeName : linkColor};

    // blockquote
    NSMutableParagraphStyle *blockquoteParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    blockquoteParagraphStyle.headIndent = 16.0;
    blockquoteParagraphStyle.tailIndent = 16.0;
    blockquoteParagraphStyle.firstLineHeadIndent = 16.0;
    self.attributes[@(BLOCKQUOTE)] = @{
        NSFontAttributeName : [emFont fontWithSize:18.0],
        NSParagraphStyleAttributeName : pParagraphStyle
    };

    // verbatim (code)
    NSMutableParagraphStyle *verbatimParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    verbatimParagraphStyle.headIndent = 12.0;
    verbatimParagraphStyle.firstLineHeadIndent = 12.0;
    UIFont *verbatimFont = [UIFont fontWithName:@"CourierNewPSMT" size:14.0];
    self.attributes[@(VERBATIM)] = @{
        NSFontAttributeName : verbatimFont,
        NSParagraphStyleAttributeName : verbatimParagraphStyle
    };
}

- (NSMutableAttributedString *)renderMarkdown:(NSString *)text {
    NSMutableAttributedString *attributedString = markdown_to_attr_string(text, 0, self.attributes);
    [attributedString
        enumerateAttribute:@"attributedMarkdownURL"
                   inRange:NSMakeRange(0, attributedString.length)
                   options:0
                usingBlock:^(id _Nullable attributeValue, NSRange range, BOOL *_Nonnull stop) {
                    if (attributeValue) {
                        [attributedString addAttribute:NSLinkAttributeName
                                                 value:attributeValue
                                                 range:range];
                    }
                }];
    return attributedString;
}

@end
