//
//  HRPGInviteMembersViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 26/09/15.
//  Copyright © 2015 Phillip Thelen. All rights reserved.
//

#import "XLFormViewController.h"

@interface HRPGInviteMembersViewController : XLFormViewController

@property(weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@property NSString *invitationType;
@property NSArray *members;

@end
