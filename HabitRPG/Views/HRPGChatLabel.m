#import "HRPGChatLabel.h"

@interface HRPGChatLabel ()

@property(nonatomic, retain, readonly) NSMutableArray *linkRanges;

@end

@implementation HRPGChatLabel

@synthesize linkRanges = _linkRanges;

- (NSMutableArray *) linkRanges {
  if (_linkRanges) { return _linkRanges; }
  _linkRanges = [@[] mutableCopy];
  return _linkRanges;
}

@end
