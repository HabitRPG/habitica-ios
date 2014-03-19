//
//  HRPGManager.h
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface HRPGManager : NSObject

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

- (void) loadObjectManager;
-(void) fetchTasks:(void (^)())successBlock onError:(void (^)())errorBlock;
-(void) fetchUser:(void (^)())successBlock onError:(void (^)())errorBlock;
-(void) fetchParty:(void (^)())successBlock onError:(void (^)())errorBlock;
-(void) upDownTask:(Task*)task direction:(NSString*)withDirection onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;
-(void) updateTask:(Task*)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;
-(void) loginUser:(NSString*)username withPassword:(NSString*)password onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock;
-(NSManagedObjectContext *) getManagedObjectContext;
- (void) displayNetworkError;
- (void) setCredentials;

-(UIColor*) getColorForValue:(NSNumber*) value;

@end
