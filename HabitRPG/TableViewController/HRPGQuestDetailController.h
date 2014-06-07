//
//  HRPGQuestDetailController.h
//  RabbitRPG
//
//  Created by Phillip Thelen on 08/05/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGBaseViewController.h"
#import "Quest.h"

@interface HRPGQuestDetailController : HRPGBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property Quest *quest;

@end
