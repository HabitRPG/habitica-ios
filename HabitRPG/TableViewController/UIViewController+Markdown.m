//
//  HRPGTableViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 04/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import "UIViewController+Markdown.h"
#import "markdown_lib.h"
#import "markdown_peg.h"
#import "UIColor+Habitica.h"

@implementation UIViewController (Markdown)

@dynamic attributes;

- (void) configureMarkdownAttributes {
    self.attributes = [[NSMutableDictionary alloc]init];
    
    // p
    
    UIFont *paragraphFont = [UIFont systemFontOfSize:15.0f];
    NSMutableParagraphStyle* pParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    pParagraphStyle.paragraphSpacing = 4;
    pParagraphStyle.paragraphSpacingBefore = 4;
    NSDictionary *pAttributes = @{
                                  NSFontAttributeName : paragraphFont,
                                  NSParagraphStyleAttributeName : pParagraphStyle,
                                  };
    
    [self.attributes setObject:pAttributes forKey:@(PARA)];
    
    // h1
    UIFont *h1Font = [UIFont boldSystemFontOfSize:24.0f];
    [self.attributes setObject:@{NSFontAttributeName : h1Font} forKey:@(H1)];
    
    // h2
    UIFont *h2Font = [UIFont boldSystemFontOfSize:18.0f];
    [self.attributes setObject:@{NSFontAttributeName : h2Font} forKey:@(H2)];
    
    // h3
    UIFont *h3Font = [UIFont boldSystemFontOfSize:17.0f];
    [self.attributes setObject:@{NSFontAttributeName : h3Font} forKey:@(H3)];
    
    // em
    UIFont *emFont = [UIFont italicSystemFontOfSize:15.0f];
    [self.attributes setObject:@{NSFontAttributeName : emFont} forKey:@(EMPH)];
    
    // strong
    UIFont *strongFont = [UIFont boldSystemFontOfSize:15.0f];
    [self.attributes setObject:@{NSFontAttributeName : strongFont} forKey:@(STRONG)];
    
    // ul
    NSMutableParagraphStyle* listParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    listParagraphStyle.headIndent = 16.0;
    [self.attributes setObject:@{NSFontAttributeName : paragraphFont, NSParagraphStyleAttributeName : listParagraphStyle} forKey:@(BULLETLIST)];
    
    // li
    NSMutableParagraphStyle* listItemParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    listItemParagraphStyle.headIndent = 16.0;
    [self.attributes setObject:@{NSFontAttributeName : paragraphFont, NSParagraphStyleAttributeName : listItemParagraphStyle} forKey:@(LISTITEM)];
    
    // a
    UIColor *linkColor = [UIColor purple400];
    [self.attributes setObject:@{NSForegroundColorAttributeName : linkColor} forKey:@(LINK)];
    
    // blockquote
    NSMutableParagraphStyle* blockquoteParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    blockquoteParagraphStyle.headIndent = 16.0;
    blockquoteParagraphStyle.tailIndent = 16.0;
    blockquoteParagraphStyle.firstLineHeadIndent = 16.0;
    [self.attributes setObject:@{NSFontAttributeName : [emFont fontWithSize:18.0], NSParagraphStyleAttributeName : pParagraphStyle} forKey:@(BLOCKQUOTE)];
    
    // verbatim (code)
    NSMutableParagraphStyle* verbatimParagraphStyle = [[NSMutableParagraphStyle alloc]init];
    verbatimParagraphStyle.headIndent = 12.0;
    verbatimParagraphStyle.firstLineHeadIndent = 12.0;
    UIFont *verbatimFont = [UIFont fontWithName:@"CourierNewPSMT" size:14.0];
    [self.attributes setObject:@{NSFontAttributeName : verbatimFont, NSParagraphStyleAttributeName : verbatimParagraphStyle} forKey:@(VERBATIM)];
}

- (NSMutableAttributedString *) renderMarkdown:(NSString *)text {
    NSMutableAttributedString *attributedString = markdown_to_attr_string(text,0,self.attributes);
    [attributedString enumerateAttribute:@"attributedMarkdownURL" inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id _Nullable attributeValue, NSRange range, BOOL * _Nonnull stop) {
        if (attributeValue) {
            [attributedString addAttribute:NSLinkAttributeName value:attributeValue range:range];
        }
    }];
    return attributedString;
}

@end
