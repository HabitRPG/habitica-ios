#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HRPGChatLabel.h"

@interface HRPGChatLabel (XCTESTS)

- (NSArray *) URLRanges;
- (void) findURLRanges:(NSString *) text;

@end

@interface HRPGChatLabelTest : XCTestCase

@property(nonatomic, strong) HRPGChatLabel *label;

@end

@implementation HRPGChatLabelTest

- (void) setUp {
  [super setUp];
  self.label = [[HRPGChatLabel alloc] initWithFrame:CGRectZero];
}

- (void) tearDown {
  [super tearDown];
}

- (void) testLabelHasRecognizer {
  NSArray *recognizers = [self.label gestureRecognizers];
  XCTAssertEqualObjects(@([recognizers count]), @(1));
  id recognizer = recognizers[0];
  XCTAssertTrue([recognizer isKindOfClass:[UITapGestureRecognizer class]]);
}

- (void) testAllowsUserInteraction {
  XCTAssertEqualObjects(@([[self label] isUserInteractionEnabled]), @(1));
}

- (void) testFindURLRangeNone {
  NSString *text = @"string";

  [self.label findURLRanges:text];

  NSArray *matches = [self.label URLRanges];
  XCTAssertEqualObjects(@([matches count]), @(0));
}

- (void) testFindURLRangeOne {
  NSString *url = @"https://gist.github.com/jmoody/ccd1d44085f829cc44e9";
  NSString *text = [NSString stringWithFormat:@"This gist: %@ shows an example",
                    url];

  [self.label findURLRanges:text];

  NSArray *matches = [self.label URLRanges];
  XCTAssertEqualObjects(@([matches count]), @(1));

  NSTextCheckingResult *match = matches[0];
  NSRange range = match.range;
  XCTAssertEqualObjects(@(range.location), @(11));
  XCTAssertEqualObjects(@(range.length), @(51));
}

- (void) testFindURLRangeSeveral {
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

  [self.label findURLRanges:text];

  NSArray *matches = [self.label URLRanges];
  XCTAssertEqualObjects(@([matches count]), @(3));
}

- (void) testSetAttributedTextCallsFindURLRanges {
  NSString *url = @"https://gist.github.com/jmoody/ccd1d44085f829cc44e9";
  NSString *text = [NSString stringWithFormat:@"This gist: %@ shows an example",
                    url];
  NSAttributedString *atrributed = [[NSAttributedString alloc]
                                initWithString:text];

  self.label.attributedText = atrributed;

  [self.label findURLRanges:text];

  NSArray *matches = [self.label URLRanges];
  XCTAssertEqualObjects(@([matches count]), @(1));

  // Unexpected: label.attributedText != attributed
  XCTAssertEqualObjects(self.label.attributedText.string, atrributed.string);
}

@end
