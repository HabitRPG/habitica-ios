#import "HRPGChatLabel.h"

@interface HRPGChatLabel ()

@property(nonatomic, retain) NSArray *URLRanges;

- (void) findURLRanges:(NSString *) text;

@end

@implementation HRPGChatLabel

- (BOOL) isUserInteractionEnabled {
  return YES;
}

- (void) findURLRanges:(NSString *) text {
  NSError *error = NULL;
  NSDataDetector *detector;
  detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                             error:&error];

  if (error) {
    NSLog(@"Error detecting URLs in chat text: %@",
          [error localizedDescription]);
    return;
  }

  self.URLRanges = [detector matchesInString:text
                                     options:0
                                       range:NSMakeRange(0, [text length])];
}

@end
