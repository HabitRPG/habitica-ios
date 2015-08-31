#import "HRPGChatLabel.h"

@interface HRPGChatLabel ()

@property(nonatomic, retain) NSArray *URLRanges;

- (void) findURLRanges:(NSString *) text;
- (void) handleTapWithRecognizer:(UITapGestureRecognizer *) recognizer;

@end

@implementation HRPGChatLabel

- (instancetype) initWithFrame:(CGRect) frame {
  self = [super initWithFrame:frame];
  if (self) {
    UITapGestureRecognizer *recognizer;
    recognizer = [[UITapGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(handleTapWithRecognizer:)];
    [self addGestureRecognizer:recognizer];
  }
  return self;
}

- (BOOL) isUserInteractionEnabled {
  return YES;
}

- (void) handleTapWithRecognizer:(UITapGestureRecognizer *) recognizer {
  NSLog(@"Handling tap on chat label");
}

- (void) setAttributedText:(NSAttributedString *)attributedText {
  [self findURLRanges:attributedText.string];

  [super setAttributedText:attributedText];
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

