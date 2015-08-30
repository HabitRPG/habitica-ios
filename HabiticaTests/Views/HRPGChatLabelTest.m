#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HRPGChatLabel.h"

@interface HRPGChatLabel (XCTESTS)

- (NSMutableArray *) linkRanges;
- (void) addLinkRange:(NSRange) range;

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

- (void) testLinkRanges {
  NSMutableArray *array = [self.label linkRanges];
  XCTAssertTrue([array isKindOfClass:[NSMutableArray class]]);
  XCTAssertEqual(array, [self.label linkRanges]);
}

- (void) testAddLinkRange {
  NSRange range = NSMakeRange(0, 1);
  NSString *expected = NSStringFromRange(range);

  [self.label addLinkRange:range];
  NSArray *ranges = [self.label linkRanges];

  XCTAssertEqualObjects(@([ranges count]), @(1));

  NSString *actual = ranges[0];
  XCTAssertEqualObjects(actual, expected);

  NSRange fromString = NSRangeFromString(actual);
  XCTAssertEqualObjects(@(range.location), @(fromString.location));
  XCTAssertEqualObjects(@(range.length), @(fromString.length));
}

- (void) testAllowsUserInteraction {
  XCTAssertEqualObjects(@([[self label] isUserInteractionEnabled]), @(1));
}

@end
