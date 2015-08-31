#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HRPGChatLabel.h"

@interface NSString (XCTEST)

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
              constrainedToSize:(CGSize) aSize;

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
              constrainedToSize:(CGSize) aSize
                  lineBreakMode:(NSLineBreakMode) aLineBreakMode;

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
                    minFontSize:(CGFloat) aMinSize
                 actualFontSize:(CGFloat *) aActualFontSize
                       forWidth:(CGFloat) aWidth
                  lineBreakMode:(NSLineBreakMode) aLineBreakMode;


@end

@implementation NSString (XCTEST)

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
              constrainedToSize:(CGSize) aSize {
  return [self sizeOfStringWithFont:aFont
                  constrainedToSize:aSize
                      lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
              constrainedToSize:(CGSize) aSize
                  lineBreakMode:(NSLineBreakMode) aLineBreakMode {
  NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:aSize];
  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];
  [textStorage addAttribute:NSFontAttributeName
                      value:aFont
                      range:NSMakeRange(0, self.length)];
  [textContainer setLineBreakMode:aLineBreakMode];
  [textContainer setLineFragmentPadding:0.0];
  (void)[layoutManager glyphRangeForTextContainer:textContainer];
  return [layoutManager usedRectForTextContainer:textContainer].size;
}

- (CGSize) sizeOfStringWithFont:(UIFont *) aFont
                    minFontSize:(CGFloat) aMinSize
                 actualFontSize:(CGFloat *) aActualFontSize
                       forWidth:(CGFloat) aWidth
                  lineBreakMode:(NSLineBreakMode) aLineBreakMode {

  CGFloat currentFontSize = aFont.pointSize;
  CGSize targetSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  CGSize currentSize = CGSizeZero;

  CGFloat lineHeight = CGFLOAT_MAX;

  do {
    UIFont *currentFont = [aFont fontWithSize:currentFontSize];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:targetSize];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName
                        value:currentFont
                        range:NSMakeRange(0, self.length)];
    [textContainer setLineBreakMode:aLineBreakMode];
    [textContainer setLineFragmentPadding:0.0];
    (void)[layoutManager glyphRangeForTextContainer:textContainer];

    currentSize = [layoutManager usedRectForTextContainer:textContainer].size;
    if (lineHeight == CGFLOAT_MAX) {  lineHeight = currentSize.height; }

    if (currentFontSize - 1.0f < aMinSize) {  break; }
    currentFontSize -= 1.0f;
  } while (currentSize.width > aWidth);
  *aActualFontSize = currentFontSize;
  return CGSizeMake(currentSize.width, lineHeight);
}

@end

@interface HRPGChatLabel (XCTESTS)

- (NSArray *) arrayOfURLRanges:(NSString *) text;
- (CGPoint) offsetForTextContainerWithBoundingBox:(CGRect) boundingBox;
- (CGPoint) pointByApplyingOffset:(CGPoint) offset toPoint:(CGPoint) point;
- (BOOL) tapAtPoint:(CGPoint) point wasWithinRange:(NSRange) range;

@end

@interface HRPGChatLabelTest : XCTestCase

@property(nonatomic, strong) HRPGChatLabel *label;
@property(nonatomic, strong) UIFont *font;

@end

@implementation HRPGChatLabelTest

- (void) setUp {
  [super setUp];
  self.label = [[HRPGChatLabel alloc] initWithFrame:CGRectZero];
  self.font = [UIFont fontWithName:@"Avenir" size:18];
  self.label.font = self.font;
}

- (void) tearDown {
  [super tearDown];
}

#pragma mark - Helpers

- (CGRect) frameAfterConfiguringLabelWithText:(NSString *) text {
  NSAttributedString *attributed;
  attributed = [[NSAttributedString alloc]
                initWithString:text];

  self.label.attributedText = attributed;

  CGSize size = [text sizeOfStringWithFont:self.font
                         constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];

  CGRect frame = CGRectMake(0, 0, size.width + 20, size.height + 16);
  self.label.frame = frame;
  return frame;
}

#pragma mark - Tests

- (void) testLabelHasRecognizer {
  NSArray *recognizers = [self.label gestureRecognizers];
  XCTAssertEqualObjects(@([recognizers count]), @(1));
  id recognizer = recognizers[0];
  XCTAssertTrue([recognizer isKindOfClass:[UITapGestureRecognizer class]]);
}

- (void) testAllowsUserInteraction {
  XCTAssertEqualObjects(@([[self label] isUserInteractionEnabled]), @(1));
}

- (void) testOffestForTextContainer {
  CGRect frame = CGRectMake(0, 0, 300, 80);
  self.label.frame = frame;

  CGRect box = CGRectMake(10, 10, 260, 20);

  CGPoint actual = [self.label offsetForTextContainerWithBoundingBox:box];
  CGPoint expected = CGPointMake(10, 20);

  XCTAssertEqualObjects(@(actual.x), @(expected.x));
  XCTAssertEqualObjects(@(actual.y), @(expected.y));
}

- (void) testPointByApplyingOffset {
  CGPoint offset = CGPointMake(10, 20);
  CGPoint point = CGPointMake(20, 40);

  CGPoint actual = [self.label pointByApplyingOffset:offset toPoint:point];
  CGPoint expected = CGPointMake(10, 20);

  XCTAssertEqualObjects(@(actual.x), @(expected.x));
  XCTAssertEqualObjects(@(actual.y), @(expected.y));
}

- (void) testTapAtPointWasWithRangeReturnsNO {
  NSString *url = @"https://gist.github.com/jmoody/ccd1d44085f829cc44e9";
  NSString *text = [NSString stringWithFormat:@"This gist! %@ shows an example",
                    url];

  CGRect frame = [self frameAfterConfiguringLabelWithText:text];
  NSTextCheckingResult *match = [self.label arrayOfURLRanges:text][0];
  NSRange range = match.range;

  CGPoint touch;

  // Touches the '!' in 'gist!:'
  touch = CGPointMake(80, frame.size.height/2);
  XCTAssertFalse([self.label tapAtPoint:touch wasWithinRange:range]);

  // Touches the 'x' in 'example'
  touch = CGPointMake(635, frame.size.height/2);
  XCTAssertFalse([self.label tapAtPoint:touch wasWithinRange:range]);

  // Touches above the link.
  touch = CGPointMake(400, 4);
  XCTAssertFalse([self.label tapAtPoint:touch wasWithinRange:range]);

  // Touches below the link.
  touch = CGPointMake(400, frame.size.height - 4);
  XCTAssertFalse([self.label tapAtPoint:touch wasWithinRange:range]);
}

- (void) testTapAtPointWasWithRangeReturnsYES {
  NSString *url = @"https://gist.github.com/jmoody/ccd1d44085f829cc44e9";
  NSString *text = [NSString stringWithFormat:@"This gist! %@ shows an example",
                    url];

  CGRect frame = [self frameAfterConfiguringLabelWithText:text];
  NSTextCheckingResult *match = [self.label arrayOfURLRanges:text][0];
  NSRange range = match.range;

  CGPoint touch;

  // Touches the ':' in 'http:'.
  touch = CGPointMake(130, frame.size.height/2);
  XCTAssertTrue([self.label tapAtPoint:touch wasWithinRange:range]);


  // Touches the 'j' in 'jmoody'.
  touch = CGPointMake(280, frame.size.height/2);
  XCTAssertTrue([self.label tapAtPoint:touch wasWithinRange:range]);

  // Touches the '9' in at the end of the URL.
  touch = CGPointMake(534, frame.size.height/2);
  XCTAssertTrue([self.label tapAtPoint:touch wasWithinRange:range]);
}

- (void) testArrayOfURLRangesNone {
  NSString *text = @"string";

  NSArray *matches = [self.label arrayOfURLRanges:text];

  XCTAssertEqualObjects(@([matches count]), @(0));
}

- (void) testArrayOfURLRangesOne {
  NSString *url = @"https://gist.github.com/jmoody/ccd1d44085f829cc44e9";
  NSString *text = [NSString stringWithFormat:@"This gist: %@ shows an example",
                    url];

  NSArray *matches = [self.label arrayOfURLRanges:text];
  XCTAssertEqualObjects(@([matches count]), @(1));

  NSTextCheckingResult *match = matches[0];
  NSRange range = match.range;
  XCTAssertEqualObjects(@(range.location), @(11));
  XCTAssertEqualObjects(@(range.length), @(51));
}

- (void) testArrayOfURLRangesSeveral {
  NSArray *lines =
  @[
    @"Here are some more gists:",
    @" * https://gist.github.com/jmoody/ccd1d44085f829cc44e9",
    @" * https://gist.github.com/jmoody/7f840e29f7829059707b",
    @" * https://gist.github.com/jmoody/cab1f0530f1c1035ac70",
    @"",
    @"As you can see, it is quite complicated. :)"
    ];
  NSString *text = [lines componentsJoinedByString:@"\n"];

  NSArray *matches = [self.label arrayOfURLRanges:text];
  XCTAssertEqualObjects(@([matches count]), @(3));
}

@end
