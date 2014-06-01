//
//  HRPGMessageViewController.h
//  RabbitRPG
//
//  Created by Phillip Thelen on 24/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface HRPGMessageViewController : UIViewController <UITextViewDelegate>

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextView *messageView;

@end
