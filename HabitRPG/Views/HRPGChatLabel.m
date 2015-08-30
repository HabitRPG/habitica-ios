#import "HRPGChatLabel.h"

@interface HRPGChatLabel ()

@property(nonatomic, retain, readonly) NSMutableArray *linkRanges;

- (void) addLinkRange:(NSRange) range;

@end

@implementation HRPGChatLabel

@synthesize linkRanges = _linkRanges;

- (NSMutableArray *) linkRanges {
  if (_linkRanges) { return _linkRanges; }
  _linkRanges = [@[] mutableCopy];
  return _linkRanges;
}

- (void) addLinkRange:(NSRange) range {
  NSString *string = NSStringFromRange(range);
  [self.linkRanges addObject:string];
}

@end
