//
//  HRPGCheckBoxView.m
//  Habitica
//
//  Created by viirus on 01.03.15.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGCheckBoxView.h"
#import "UIColor+Habitica.h"
#import "Habitica-Swift.h"

@interface HRPGCheckmarkLayer : CALayer
@property  CGFloat drawPercentage;
@end

@implementation HRPGCheckmarkLayer
@dynamic drawPercentage;

- (instancetype)init
{
    if (self = [super init])
    {
        self.drawPercentage = 0.0;
    }
    return self;
}

- (instancetype)initWithLayer: (id)layer
{
    if ((self = [super initWithLayer: layer]))
    {
        if ([layer isKindOfClass: HRPGCheckmarkLayer.class])
        {
            self.drawPercentage = ((HRPGCheckmarkLayer *)layer).drawPercentage;
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey: (NSString*)key
{
    if([key isEqualToString: @"drawPercentage"])
        return YES;
    
    return [super needsDisplayForKey: key];
}


- (id<CAAction>)actionForKey: (NSString *)event
{
    
    if([event isEqualToString: @"drawPercentage"])
    {
        
        CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath: event];
        theAnimation.fromValue = [[self presentationLayer] valueForKey: event];
        
        return theAnimation;
    }
    
    return [super actionForKey: event];
}

@end

@interface HRPGCheckBoxView ()

@property UILabel *label;

@end



@implementation HRPGCheckBoxView

+ (Class)layerClass
{
    return [HRPGCheckmarkLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) setupView {
    self.backgroundColor = [UIColor clearColor];
    self.size = 26;
    self.padding = 12;
    self.centerCheckbox = true;
    self.borderedBox = false;
    
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapRecognizer];
    
    self.userInteractionEnabled = false;
}

- (void)configureForTask:(NSObject<HRPGTaskProtocol> *)task {
    [self configureForTask:task withOffset:0];
}

- (void)configureForTask:(NSObject<HRPGTaskProtocol> *)task withOffset:(NSInteger)offset {
    self.boxFillColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.checked = [task.completed boolValue];
    ((HRPGCheckmarkLayer *)self.layer).drawPercentage = self.checked ? 1.0f : 0.0f;
    if ([task.type isEqualToString:@"daily"]) {
        self.cornerRadius = 3;

        if ([task.completed boolValue]) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray500];
            self.checkColor = [UIColor gray200];
        } else {
            self.backgroundColor = [UIColor gray600];
            self.checkColor = [UIColor gray200];
            if ([task isKindOfClass:Task.class]) {
                Task *concreteTask = (Task *)task;
                if ([concreteTask dueTodayWithOffset:offset]) {
                    self.backgroundColor = [UIColor forTaskValueLight:concreteTask.value];
                    self.checkColor = [UIColor forTaskValue:concreteTask.value];
                }
            } else {
                self.backgroundColor = [UIColor forTaskValueLight:task.value];
                self.checkColor = [UIColor forTaskValue:task.value];
            }
        }

    } else {
        self.cornerRadius = self.size / 2;
        if ([task.completed boolValue]) {
            self.boxFillColor = [UIColor gray400];
            self.backgroundColor = [UIColor gray600];
            self.checkColor = [UIColor gray200];
        } else {
            self.backgroundColor = [UIColor forTaskValueLight:task.value];
            self.checkColor = [UIColor forTaskValue:task.value];
        }
    }

    [self.layer setNeedsDisplay];
}

- (void)configureForChecklistItem:(ChecklistItem *)item withTitle:(BOOL)withTitle {
    self.checked = [item.completed boolValue] || [item.currentlyChecking boolValue];
    ((HRPGCheckmarkLayer *)self.layer).drawPercentage = self.checked ? 1.0f : 0.0f;
    if (self.label == nil && withTitle) {
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [self addSubview:self.label];
        
        if (self.checked) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:item.text];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            self.label.attributedText = attributeString;
        } else {
            self.label.text = item.text;
        }
    }
    
    self.label.textColor = self.checked ? [UIColor gray400] : [UIColor gray100];
    self.backgroundColor = [UIColor clearColor];
    self.boxFillColor = self.checked ? [UIColor gray400] : [UIColor clearColor];
    self.boxBorderColor = self.checked ? nil : [UIColor gray400];
    self.checkColor = [UIColor gray200];
    self.cornerRadius = 3;
    self.centerCheckbox = NO;
    self.size = 22;
    self.borderedBox = true;
    [self.layer setNeedsDisplay];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    if (self.wasTouched) {
        self.checked = !self.checked;
        self.wasTouched();
        [self animateTo:self.checked ? 1.0f : 0.0f];
    }
}

- (void)animateTo: (CGFloat)toValue {
    HRPGCheckmarkLayer* layer = (HRPGCheckmarkLayer*)self.layer;
    CAMediaTimingFunction* timing = [CAMediaTimingFunction functionWithName:  kCAMediaTimingFunctionEaseInEaseOut];
    CGFloat duration = 0.2;

    CABasicAnimation* theAnimation = [CABasicAnimation animationWithKeyPath: @"drawPercentage"];
    theAnimation.additive = YES;
    theAnimation.duration = duration;
    theAnimation.fillMode = kCAFillModeBoth;
    theAnimation.timingFunction = timing;
    theAnimation.fromValue = @(layer.drawPercentage - toValue);
    theAnimation.toValue = @(0);
    
    
    [layer addAnimation: theAnimation forKey: nil];
    
    [CATransaction begin];
    [CATransaction setDisableActions: YES];
    layer.drawPercentage = toValue;
    [CATransaction commit];
}

- (void)layoutSubviews {
    CGFloat leftOffset = self.padding*2 + self.size;
    self.label.frame = CGRectMake(leftOffset, 0, self.frame.size.width-leftOffset, self.frame.size.height);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    UIGraphicsPushContext(ctx);

    CGFloat horizontalCenter = self.centerCheckbox ? self.frame.size.width / 2 : self.padding + self.size / 2;
    UIBezierPath *borderPath = [UIBezierPath
                                bezierPathWithRoundedRect:CGRectMake(horizontalCenter - self.size / 2,
                                                                     self.frame.size.height / 2 - self.size / 2, self.size,
                                                                     self.size)
                                cornerRadius:self.cornerRadius];
    if (self.boxBorderColor != nil) {
        [self.boxBorderColor setStroke];
        [borderPath stroke];
    }
    [self.boxFillColor setFill];
    [borderPath fill];
    if ([(HRPGCheckmarkLayer *)layer drawPercentage] > 0) {
        CGRect checkFrame = CGRectMake(self.padding, self.frame.size.height / 2 - self.size / 2, self.size, self.size);
        [HabiticaIcons drawCheckmarkWithFrame:checkFrame resizing:HabiticaIconsResizingBehaviorCenter checkmarkColor:self.checkColor percentage:[(HRPGCheckmarkLayer *)layer drawPercentage]];
    }
    if (self.isLocked) {
        CGFloat baseSize = self.size * 0.5;
        CGFloat lockHeight = baseSize;
        CGFloat lockWidth = baseSize * 15/17;
        CGFloat x = self.frame.size.width / 2 - lockWidth / 2 - 1;
        CGFloat y = self.frame.size.height / 2 - lockHeight / 2;
        [HabiticaIcons drawLockedWithFrame:CGRectMake(x, y, lockHeight, lockWidth) resizing:HabiticaIconsResizingBehaviorAspectFit];
    }
    UIGraphicsPopContext();
}

- (void)setWasTouched:(void (^)(void))wasTouched {
    _wasTouched = wasTouched;
    if (wasTouched != nil) {
        self.userInteractionEnabled = true;
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.size+self.padding*2, self.size+self.padding*2);
}

- (void)setIsLocked:(BOOL)isLocked {
    _isLocked = isLocked;
}

@end
