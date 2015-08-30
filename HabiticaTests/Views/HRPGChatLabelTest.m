#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "HRPGChatLabel.h"

@interface HRPGChatLabel (XCTESTS)

- (NSMutableArray *) linkRanges;

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

@end
