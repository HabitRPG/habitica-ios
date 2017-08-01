//
//  HRPGSpeechbubbleView.h
//  Habitica
//
//  Created by Phillip Thelen on 05/10/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface HRPGSpeechbubbleView : UIView


@property(nonatomic) IBInspectable NSString *text;
@property(nonatomic) IBInspectable UIColor *textColor;
@property(nonatomic) IBInspectable NSString *npcName;
@property(nonatomic) IBInspectable BOOL hideButtons;

@end
