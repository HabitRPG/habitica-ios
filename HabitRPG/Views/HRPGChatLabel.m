#import "HRPGChatLabel.h"

@interface HRPGChatLabel ()

- (NSArray *) arrayOfURLRanges:(NSString *) text;
- (void) handleTapWithRecognizer:(UITapGestureRecognizer *) recognizer;
- (BOOL) tapAtPoint:(CGPoint) point wasWithinRange:(NSRange) range;

- (CGPoint) offsetForTextContainerWithBoundingBox:(CGRect) boundingBox;
- (CGPoint) pointByApplyingOffset:(CGPoint) offset toPoint:(CGPoint) point;

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

- (CGPoint) offsetForTextContainerWithBoundingBox:(CGRect) boundingBox {
  CGSize size = self.bounds.size;
  CGSize boxSize = boundingBox.size;
  CGPoint boxOrigin = boundingBox.origin;

  return CGPointMake((size.width - boxSize.width)/2 - boxOrigin.x,
                     (size.height - boxSize.height)/2 - boxOrigin.y);
}

- (CGPoint) pointByApplyingOffset:(CGPoint) offset toPoint:(CGPoint) point {
  return CGPointMake(point.x - offset.x, point.y - offset.y);
}

- (BOOL) tapAtPoint:(CGPoint) point wasWithinRange:(NSRange) range {

  CGSize size = self.bounds.size;
  NSAttributedString *attributedText = self.attributedText;

  NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
  NSTextStorage *textStorage = [[NSTextStorage alloc]
                                initWithAttributedString:attributedText];

  // Will have consequences if string has multiple fonts...
  [textStorage addAttribute:NSFontAttributeName
                      value:self.font
                      range:NSMakeRange(0, attributedText.length)];


  [layoutManager addTextContainer:textContainer];
  [textStorage addLayoutManager:layoutManager];

  textContainer.lineFragmentPadding = 0.0;
  textContainer.lineBreakMode = self.lineBreakMode;
  textContainer.maximumNumberOfLines = self.numberOfLines;


  CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
  CGPoint offset = [self offsetForTextContainerWithBoundingBox:textBoundingBox];

  CGPoint locationOfTouch = [self pointByApplyingOffset:offset toPoint:point];

  NSUInteger index = [layoutManager characterIndexForPoint:locationOfTouch
                                           inTextContainer:textContainer
                  fractionOfDistanceBetweenInsertionPoints:nil];
  return NSLocationInRange(index, range);
}

- (void) setAttributedText:(NSAttributedString *)attributedText {
  [super setAttributedText:attributedText];
}

- (NSArray *) arrayOfURLRanges:(NSString *) text {
  NSError *error = NULL;
  NSDataDetector *detector;
  detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                             error:&error];

  if (!detector) {
    NSLog(@"Error detecting URLs in chat text: %@",
          [error localizedDescription]);
    return nil;
  }

  return [detector matchesInString:text
                           options:0
                             range:NSMakeRange(0, [text length])];
}

@end
