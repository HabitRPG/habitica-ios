//
//  HRPGManager.m
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "HRPGManager.h"
#import "Task.h"
#import "user.h"
#import "CRToast.h"
#import "HRPGTaskResponse.h"
#import "HRPGLoginData.h"
#import <PDKeychainBindings.h>

@implementation HRPGManager
@synthesize managedObjectContext;
RKManagedObjectStore *managedObjectStore;
User *user;
NSString *userID;

-(void)loadObjectManager
{
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HabitRPG" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"HabitRPG.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://habitrpg.com"]];
    objectManager.managedObjectStore = managedObjectStore;
    
    [RKObjectManager setSharedManager:objectManager];
    [RKObjectManager sharedManager].requestSerializationMIMEType = RKMIMETypeJSON;
    [objectManager.HTTPClient setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSDictionary *options = @{kCRToastTextKey : NSLocalizedString(@"No Network connection", nil),
                                      kCRToastSubtitleTextKey :NSLocalizedString(@"You need a network connection to do that.", nil),
                                      kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                                      kCRToastBackgroundColorKey : [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]};
            [CRToastManager showNotificationWithOptions:options
                                        completionBlock:^{
                                        }];
            
        }
    }];
    
    
    RKEntityMapping *taskMapping = [RKEntityMapping mappingForEntityForName:@"Task" inManagedObjectStore:managedObjectStore];
    [taskMapping addAttributeMappingsFromDictionary:@{
                                                        @"id":              @"id",
                                                        @"name":            @"name",
                                                        @"attribute":       @"attribute",
                                                        @"down":            @"down",
                                                        @"up":              @"up",
                                                        @"priority":        @"priority",
                                                        @"text":            @"text",
                                                        @"value":           @"value",
                                                        @"type":            @"type",
                                                        @"completed":       @"completed",
                                                        @"notes":           @"notes",
                                                        @"streak":          @"streak",
                                                        @"dateCreated":     @"dateCreated"}];
    taskMapping.identificationAttributes = @[ @"id" ];
    RKObjectMapping* checklistItemMapping = [RKEntityMapping mappingForEntityForName:@"ChecklistItem" inManagedObjectStore:managedObjectStore];
    [checklistItemMapping addAttributeMappingsFromArray:@[@"id", @"text", @"completed"]];
    [taskMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"checklist"
                                                                                  toKeyPath:@"checklist"
                                                                                withMapping:checklistItemMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:taskMapping method:RKRequestMethodGET pathPattern:@"/api/v2/user/tasks" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithClass:[Task class] pathPattern:@"/api/v2/user/tasks/:id" method:RKRequestMethodGET]];
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithClass:[Task class] pathPattern:@"/api/v2/user/tasks/:id" method:RKRequestMethodPUT]];
    [[RKObjectManager sharedManager].router.routeSet addRoute:[RKRoute routeWithName:@"taskdirection" pathPattern:@"/api/v2/user/tasks/:id/:direction" method:RKRequestMethodPOST]];
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/v2/user/tasks"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
            return fetchRequest;
        }
        
        return nil;
    }];
    
    RKObjectMapping *upDownMapping = [RKObjectMapping mappingForClass:[HRPGTaskResponse class]];
    [upDownMapping addAttributeMappingsFromDictionary:@{
                                                      @"delta":              @"delta",
                                                      @"gp":            @"gold",
                                                      @"lvl":       @"level",
                                                      @"hp":            @"health",
                                                      @"mp":              @"magic",
                                                      @"exp":        @"experience"}];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:upDownMapping method:RKRequestMethodGET pathPattern:@"/api/v2/user/tasks/:id/:direction" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    RKObjectMapping *loginMapping = [RKObjectMapping mappingForClass:[HRPGLoginData class]];
    [loginMapping addAttributeMappingsFromDictionary:@{
                                                        @"id":              @"id",
                                                        @"token":            @"key"}];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:loginMapping method:RKRequestMethodGET pathPattern:@"/api/v2/user/auth/local" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"_id":              @"id",
                                                        @"profile.name":            @"username",
                                                        @"stats.lvl":             @"level",
                                                        @"stats.gp":             @"gold",
                                                        @"stats.exp":             @"experience",
                                                        @"stats.mp":             @"magic",
                                                        @"stats.hp":             @"health",
                                                        @"stats.toNextLevel":             @"nextLevel",
                                                        @"stats.maxHealth":             @"maxHealth",
                                                        @"stats.maxMP":             @"maxMagic"
                                                        }];
    entityMapping.identificationAttributes = @[ @"id" ];
    RKObjectMapping* rewardMapping = [RKEntityMapping mappingForEntityForName:@"Reward" inManagedObjectStore:managedObjectStore];
    [rewardMapping addAttributeMappingsFromDictionary:@{
                                                        @"id":          @"id",
                                                        @"text":        @"text",
                                                        @"dateCreated": @"dateCreated",
                                                        @"value":       @"value"
                                                        }];
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rewards"
                                                                                   toKeyPath:@"rewards"
                                                                                 withMapping:rewardMapping]];
    RKObjectMapping* tagMapping = [RKEntityMapping mappingForEntityForName:@"Tag" inManagedObjectStore:managedObjectStore];
    [tagMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tags"
                                                                                  toKeyPath:@"tags"
                                                                                withMapping:tagMapping]];
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping method:RKRequestMethodGET pathPattern:@"/api/v2/user" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", userID];
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedObjects = [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        user = fetchedObjects[0];
        NSLog(@"%@", user.rewards);
    }
    
    
    
    entityMapping = [RKEntityMapping mappingForEntityForName:@"Group" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"_id":              @"id",
                                                        @"name":            @"name",
                                                        @"description":       @"description",
                                                        @"quest.key":            @"questKey",
                                                        @"quest.progress.hp":              @"questHP",
                                                        @"quest.active":        @"questActive",
                                                        @"privacy":         @"privacy",
                                                        @"type":                @"type"
                                                        }];
    entityMapping.identificationAttributes = @[ @"id" ];
    RKObjectMapping* memberMapping = [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [memberMapping addAttributeMappingsFromDictionary:@{
                                                        @"_id":                 @"id",
                                                        @"profile.name":        @"username"
                                                        }];
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"members"
                                                                                toKeyPath:@"member"
                                                                                withMapping:memberMapping]];
    RKObjectMapping* chatMapping = [RKEntityMapping mappingForEntityForName:@"ChatMessage" inManagedObjectStore:managedObjectStore];
    [chatMapping addAttributeMappingsFromArray:@[@"uuid", @"id", @"text", @"timestamp"]];
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"chat"
                                                                                  toKeyPath:@"chatmessages"
                                                                                withMapping:chatMapping]];
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping method:RKRequestMethodGET pathPattern:@"/api/v2/groups/:id" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"/api/v2/groups/:id"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type='party'"]];
            return fetchRequest;
        }
        
        return nil;
    }];
    [self setCredentials];
}

- (NSManagedObjectContext *)getManagedObjectContext {
    return [managedObjectStore mainQueueManagedObjectContext];
}

- (void) setCredentials {
    
    PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
    userID = [keyChain stringForKey:@"id"];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-user" value:userID];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-key" value:[keyChain stringForKey:@"key"]];
}

-(UIColor*) getColorForValue:(NSNumber *)value {
    NSInteger intValue = [value integerValue];
    if (intValue < -20) {
        return [UIColor colorWithRed:0.824 green:0.113 blue:0.104 alpha:1.000];
    } else if (intValue < -10) {
        return [UIColor colorWithRed:0.933 green:0.144 blue:0.198 alpha:1.000];
    } else if (intValue < -1) {
        return [UIColor colorWithRed:0.966 green:0.517 blue:0.117 alpha:1.000];
    } else if (intValue < 1) {
        return [UIColor colorWithRed:0.847 green:0.597 blue:0.077 alpha:1.000];
    } else if (intValue < 5) {
        return [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
    } else if (intValue < 10) {
        return [UIColor colorWithRed:0.218 green:0.600 blue:0.692 alpha:1.000];
    } else {
        return [UIColor colorWithRed:0.231 green:0.442 blue:0.964 alpha:1.000];
    }
}

- (void) fetchTasks:(void (^)())successBlock onError:(void (^)())errorBlock{
    NSLog(@"Fetching tasks");
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/v2/user/tasks" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSError *executeError = nil;
        [[self getManagedObjectContext] saveToPersistentStore:&executeError];
        successBlock();
        return;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock();
        return;
    }];
}

- (void) fetchUser:(void (^)())successBlock onError:(void (^)())errorBlock{
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/api/v2/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSError *executeError = nil;
        [[self getManagedObjectContext] saveToPersistentStore:&executeError];
        successBlock();
        return;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock();
        return;
    }];

}

- (void) fetchParty:(void (^)())successBlock onError:(void (^)())errorBlock{
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/api/v2/groups/%@", @"22019889-582a-4443-bbec-8e02aba6a92b"] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSError *executeError = nil;
        [[self getManagedObjectContext] saveToPersistentStore:&executeError];
        successBlock();
        return;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock();
        return;
    }];
}

-(void) upDownTask:(Task*)task direction:(NSString*)withDirection onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [[RKObjectManager sharedManager] postObject:nil path:[NSString stringWithFormat:@"/api/v2/user/tasks/%@/%@", task.id, withDirection] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSError *executeError = nil;
        HRPGTaskResponse *taskResponse = (HRPGTaskResponse*)[mappingResult firstObject];
        task.value = [NSNumber numberWithFloat:[task.value floatValue] + [taskResponse.delta floatValue]];
        NSNumber *expDiff = [NSNumber numberWithFloat: [taskResponse.experience floatValue] - [user.experience floatValue]];
        user.experience = taskResponse.experience;
        NSNumber *healthDiff = [NSNumber numberWithFloat: [taskResponse.health floatValue] - [user.health floatValue]];
        user.health = taskResponse.health;
        user.magic = taskResponse.magic;
        user.level = taskResponse.level;
        NSNumber *goldDiff = [NSNumber numberWithFloat: [taskResponse.gold floatValue] - [user.gold floatValue]];
        user.gold = taskResponse.gold;
        [self displaySuccessNotification:healthDiff withExperienceDiff:expDiff withGoldDiff:goldDiff];
        if ([task.type  isEqual: @"daily"] || [task.type  isEqual: @"todo"]) {
            task.completed = ([withDirection  isEqual: @"up"]);
        }
        [[self getManagedObjectContext] saveToPersistentStore:&executeError];
        successBlock();
        return;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock();
        return;
    }];
}

-(void) loginUser:(NSString *)username withPassword:(NSString *)password onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    NSDictionary *params = @{@"username": username, @"password": password};
    [[RKObjectManager sharedManager] postObject:Nil path:@"/api/v2/user/auth/local" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HRPGLoginData *loginData = (HRPGLoginData*)[mappingResult firstObject];
        PDKeychainBindings *keyChain = [PDKeychainBindings sharedKeychainBindings];
        [keyChain setString:loginData.id forKey:@"id"];
        [keyChain setString:loginData.key forKey:@"key"];
        
        successBlock();
        return;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        errorBlock();
        return;
    }];

}

- (void) displayNetworkError {
    NSDictionary *options = @{kCRToastTextKey : NSLocalizedString(@"Network error", nil),
                              kCRToastSubtitleTextKey :NSLocalizedString(@"Couldn't connect to the server. Check your network connection", nil),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastBackgroundColorKey : [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f]};
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                }];
}

-(void) displaySuccessNotification:(NSNumber*) healthDiff withExperienceDiff:(NSNumber*)expDiff withGoldDiff:(NSNumber*)goldDiff {
    UIColor *notificationColor = [UIColor colorWithRed:0.251 green:0.662 blue:0.127 alpha:1.000];
    NSString *content;
    if ([healthDiff intValue] < 0) {
        notificationColor = [UIColor colorWithRed:1.0f green:0.22f blue:0.22f alpha:1.0f];
        content = [NSString stringWithFormat:@"Health: %.1f", [healthDiff floatValue]];
    } else {
        content = [NSString stringWithFormat:@"Experience: %ld\nGold: %.2f", (long)[expDiff integerValue], [goldDiff floatValue]];
    }
    NSDictionary *options = @{kCRToastTextKey : content,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastBackgroundColorKey : notificationColor};
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                }];
}

@end
