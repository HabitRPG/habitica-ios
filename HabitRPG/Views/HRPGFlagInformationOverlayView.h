//
//  HRPGFlagInformationOverlayView.h
//  Habitica
//
//  Created by Phillip Thelen on 11/02/16.
//  Copyright © 2016 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPGFlagInformationOverlayView : UIView

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *message;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextView *explanationTextView;

@property (nonatomic, copy) void (^flagAction)();

@end
