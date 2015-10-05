#import <UIKit/UIKit.h>

typedef BOOL(^HPGChatLabelURLTouchedBlock) (NSURL *url);

@interface HRPGChatLabel : UILabel

@property (nonatomic, copy) HPGChatLabelURLTouchedBlock URLTouchedBlock;

@end
