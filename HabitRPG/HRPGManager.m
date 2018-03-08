//
//  HRPGManager.m
//  HabitRPG
//
//  Created by Phillip Thelen on 09/03/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGManager.h"
#import <Crashlytics/Crashlytics.h>
#import "HRPGTaskResponse.h"
#import "HRPGLoginData.h"
#import <Google/Analytics.h>
#import "Gear.h"
#import "YYWebImage.h"
#import "Amplitude.h"
#import "HRPGEmptySerializer.h"
#import "Customization.h"
#import "Gear.h"
#import "HRPGAppDelegate.h"
#import "HRPGContentResponse.h"
#import "HRPGDeathView.h"
#import "HRPGEmptySerializer.h"
#import "HRPGImageOverlayView.h"
#import "HRPGLoginData.h"
#import "UIColor+Habitica.h"
#import "HRPGNetworkIndicatorController.h"
#import <Crashlytics/Crashlytics.h>
#import "HRPGSharingManager.h"
#import "HRPGTaskResponse.h"
#import "UIView+Screenshot.h"
#import "HRPGUserBuyResponse.h"
#import "Quest+CoreDataClass.h"
#import "Reward.h"
#import "ChecklistItem.h"
#import "UIColor+Habitica.h"
#import "HRPGURLParser.h"
#import "HRPGResponseMessage.h"
#import "NSString+StripHTML.h"
#import "PushDevice.h"
#import "Shop.h"
#import "UIView+ScreenShot.h"
#import "HRPGNotification.h"
#import "HRPGNotificationManager.h"
#import "ShopItem+CoreDataClass.h"
#import "Habitica-Swift.h"
#import <Keys/HabiticaKeys.h>
#import "NSString+Emoji.h"

@interface HRPGManager ()
@property HRPGNetworkIndicatorController *networkIndicatorController;
@property HRPGNotificationManager *notificationManager;
@property ConfigRepository *configRepository;
@property NSString *lastDeletedTaskID;
@end

@implementation HRPGManager {
}
@synthesize managedObjectContext;
RKManagedObjectStore *managedObjectStore;
NSUserDefaults *defaults;
NSString *currentUser;
static HRPGManager *sharedManager = nil;
static dispatch_once_t onceToken;


+ (HRPGManager *)sharedManager {
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        [sharedManager loadObjectManager:nil];
    });
    return sharedManager;
}

+ (HRPGManager *)uninitializedSharedManager {
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+ (RKValueTransformer *)millisecondsSince1970ToDateValueTransformer {
    return [RKBlockValueTransformer
        valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class sourceClass,
                                                  __unsafe_unretained Class destinationClass) {
            return [sourceClass isSubclassOfClass:[NSNumber class]] &&
                   [destinationClass isSubclassOfClass:[NSDate class]];
        }
        transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue,
                                  __unsafe_unretained Class outputValueClass,
                                  NSError *__autoreleasing *error) {
            RKValueTransformerTestInputValueIsKindOfClass(inputValue, (@[ [NSNumber class] ]),
                                                          error);
            RKValueTransformerTestOutputValueClassIsSubclassOfClass(outputValueClass,
                                                                    (@[ [NSDate class] ]), error);
            *outputValue =
                [NSDate dateWithTimeIntervalSince1970:([inputValue longLongValue] / 1000)];
            return YES;
        }];
}

- (void)loadObjectManager:(RKManagedObjectStore *)existingManagedObjectStore {
    self.notificationManager = [[HRPGNotificationManager alloc] initWithSharedManager:self];
    self.configRepository = [[ConfigRepository alloc] init];
    NSError *error = nil;
    NSURL *modelURL =
        [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Habitica" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    if (!existingManagedObjectStore) {
        NSManagedObjectModel *managedObjectModel =
            [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
        managedObjectStore =
            [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];

        // Initialize the Core Data stack
        [managedObjectStore createPersistentStoreCoordinator];

        NSString *storePath =
            [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Habitica.sqlite"];
        NSDictionary *options = @{
            NSMigratePersistentStoresAutomaticallyOption : @YES,
            NSInferMappingModelAutomaticallyOption : @YES
        };
        NSPersistentStore *persistentStore =
            [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                        fromSeedDatabaseAtPath:nil
                                             withConfiguration:nil
                                                       options:options
                                                         error:&error];

        NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);

        // Create the managed object contexts
        [managedObjectStore createManagedObjectContexts];
    } else {
        managedObjectStore = existingManagedObjectStore;
    }

    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc]
        initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];

    NSString *ROOT_URL = nil;
    defaults = [NSUserDefaults standardUserDefaults];

#ifdef DEBUG
    NSString *CUSTOM_DOMAIN = [defaults stringForKey:@"CUSTOM_DOMAIN"];
    NSString *DISABLE_SSL = [defaults stringForKey:@"DISABLE_SSL"];

    if (CUSTOM_DOMAIN.length == 0) {
        CUSTOM_DOMAIN = @"habitica.com/";
    }

    if (![[CUSTOM_DOMAIN substringFromIndex: [CUSTOM_DOMAIN length] - 1]  isEqual: @"/"]) {
        CUSTOM_DOMAIN = [CUSTOM_DOMAIN stringByAppendingString:@"/"];
    }


    if ([DISABLE_SSL isEqualToString:@"true"]) {
        ROOT_URL = [NSString stringWithFormat:@"http://%@", CUSTOM_DOMAIN];
    } else {
        ROOT_URL = [NSString stringWithFormat:@"https://%@", CUSTOM_DOMAIN];
    }
#else
    ROOT_URL = @"https://habitica.com/";
#endif

    ROOT_URL = [ROOT_URL stringByAppendingString:@"api/v3/"];



    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    RKObjectManager *objectManager =
        [RKObjectManager managerWithBaseURL:[NSURL URLWithString:ROOT_URL]];
    objectManager.managedObjectStore = managedObjectStore;

    [RKObjectManager setSharedManager:objectManager];
    [RKObjectManager sharedManager].requestSerializationMIMEType = RKMIMETypeJSON;
    /*[objectManager.HTTPClient setReachabilityStatusChangeBlock:^(
                                  AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown) {
            return;
        }
        if (status == AFNetworkReachabilityStatusNotReachable) {
            UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"Connection Error", nil)
                          message:NSLocalizedString(@"There is no internet connection. You will "
                                                    @"not be able to perform any actions.",
                                                    nil)
                         delegate:self
                cancelButtonTitle:NSLocalizedString(@"OK", nil)
                otherButtonTitles:nil, nil];

            [alertView show];
        }
    }];*/

    RKValueTransformer *transformer = [HRPGManager millisecondsSince1970ToDateValueTransformer];
    [[RKValueTransformer defaultValueTransformer] insertValueTransformer:transformer atIndex:0];

    RKEntityMapping *taskMapping =
        [RKEntityMapping mappingForEntityForName:@"Task" inManagedObjectStore:managedObjectStore];
    [taskMapping addAttributeMappingsFromDictionary:@{
        @"_id" : @"id",
        @"attribute" : @"attribute",
        @"down" : @"down",
        @"up" : @"up",
        @"priority" : @"priority",
        @"text" : @"text",
        @"value" : @"value",
        @"type" : @"type",
        @"completed" : @"completed",
        @"notes" : @"notes",
        @"streak" : @"streak",
        @"dateCreated" : @"dateCreated",
        @"repeat.m" : @"monday",
        @"repeat.t" : @"tuesday",
        @"repeat.w" : @"wednesday",
        @"repeat.th" : @"thursday",
        @"repeat.f" : @"friday",
        @"repeat.s" : @"saturday",
        @"repeat.su" : @"sunday",
        @"date" : @"duedate",
        @"tags" : @"tagArray",
        @"everyX" : @"everyX",
        @"frequency" : @"frequency",
        @"startDate" : @"startDate",
        @"challenge.id" : @"challengeID",
        @"daysOfMonth" : @"daysOfMonth",
        @"weeksOfMonth" : @"weeksOfMonth",
        @"isDue": @"isDue",
        @"nextDue": @"nextDue",
        @"yesterDaily": @"yesterDaily",
        @"counterUp": @"counterUp",
        @"counterDown": @"counterDown"
    }];
    taskMapping.identificationAttributes = @[ @"id" ];
    RKEntityMapping *checklistItemMapping =
        [RKEntityMapping mappingForEntityForName:@"ChecklistItem"
                            inManagedObjectStore:managedObjectStore];
    [checklistItemMapping addAttributeMappingsFromArray:@[ @"id", @"text", @"completed" ]];
    checklistItemMapping.identificationAttributes = @[ @"id", @"text" ];

    [taskMapping addPropertyMapping:[RKRelationshipMapping
                                        relationshipMappingFromKeyPath:@"checklist"
                                                             toKeyPath:@"checklist"
                                                           withMapping:checklistItemMapping]];
    RKEntityMapping *remindersMapping =
        [RKEntityMapping mappingForEntityForName:@"Reminder"
                            inManagedObjectStore:managedObjectStore];
    [remindersMapping addAttributeMappingsFromArray:@[ @"id", @"startDate", @"time" ]];
    remindersMapping.identificationAttributes = @[ @"id" ];

    [taskMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reminders"
                                                                       toKeyPath:@"reminders"
                                                                     withMapping:remindersMapping]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Task class]
                             pathPattern:@"tasks/:id"
                                  method:RKRequestMethodGET]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Task class]
                             pathPattern:@"tasks/:id"
                                  method:RKRequestMethodPUT]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Task class]
                             pathPattern:@"tasks/user"
                                  method:RKRequestMethodPOST]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Task class]
                             pathPattern:@"tasks/:id"
                                  method:RKRequestMethodDELETE]];

    RKObjectMapping *taskRequestMapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [taskRequestMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"_id",
        @"attribute" : @"attribute",
        @"down" : @"down",
        @"up" : @"up",
        @"priority" : @"priority",
        @"text" : @"text",
        @"value" : @"value",
        @"type" : @"type",
        @"completed" : @"completed",
        @"notes" : @"notes",
        @"streak" : @"streak",
        @"dateCreated" : @"dateCreated",
        @"monday" : @"repeat.m",
        @"tuesday" : @"repeat.t",
        @"wednesday" : @"repeat.w",
        @"thursday" : @"repeat.th",
        @"friday" : @"repeat.f",
        @"saturday" : @"repeat.s",
        @"sunday" : @"repeat.su",
        @"duedate" : @"date",
        @"tagArray" : @"tags",
        @"everyX" : @"everyX",
        @"frequency" : @"frequency",
        @"startDate" : @"startDate",
        @"daysOfMonth" : @"daysOfMonth",
        @"weeksOfMonth" : @"weeksOfMonth",
        @"yesterDaily": @"yesterDaily"
    }];
    RKObjectMapping *checklistItemRequestMapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [checklistItemRequestMapping addAttributeMappingsFromArray:@[ @"id", @"text", @"completed" ]];
    [taskRequestMapping
        addPropertyMapping:[RKRelationshipMapping
                               relationshipMappingFromKeyPath:@"checklist"
                                                    toKeyPath:@"checklist"
                                                  withMapping:checklistItemRequestMapping]];
    RKObjectMapping *reminderRequestmapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [reminderRequestmapping addAttributeMappingsFromArray:@[ @"id", @"startDate", @"time" ]];
    [taskRequestMapping
        addPropertyMapping:[RKRelationshipMapping
                               relationshipMappingFromKeyPath:@"reminders"
                                                    toKeyPath:@"reminders"
                                                  withMapping:reminderRequestmapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:taskMapping
                               method:RKRequestMethodPUT
                          pathPattern:@"tasks/:id"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:taskMapping
                               method:RKRequestMethodDELETE
                          pathPattern:@"tasks/:id"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    RKRequestDescriptor *requestDescriptor =
        [RKRequestDescriptor requestDescriptorWithMapping:taskRequestMapping
                                              objectClass:[Task class]
                                              rootKeyPath:nil
                                                   method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];

    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithName:@"taskdirection"
                            pathPattern:@"tasks/:id/score/:direction"
                                 method:RKRequestMethodPOST]];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:taskMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"tasks/user"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:taskRequestMapping
                                                              objectClass:[Task class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager addRequestDescriptor:requestDescriptor];

    RKEntityMapping *rewardMapping =
        [RKEntityMapping mappingForEntityForName:@"Reward" inManagedObjectStore:managedObjectStore];
    [rewardMapping addAttributeMappingsFromDictionary:@{
        @"_id" : @"key",
        @"text" : @"text",
        @"dateCreated" : @"dateCreated",
        @"value" : @"value",
        @"type" : @"type",
        @"notes" : @"notes",
        @"@metadata.mapping.collectionIndex" : @"order",
        @"tags" : @"tagArray"
    }];
    rewardMapping.identificationAttributes = @[ @"key" ];

    RKObjectMapping *rewardRequestMapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [rewardRequestMapping addAttributeMappingsFromDictionary:@{
        @"key" : @"_id",
        @"text" : @"text",
        @"value" : @"value",
        @"notes" : @"notes",
        @"type" : @"type",
        @"tagArray" : @"tags"
    }];

    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Reward class]
                             pathPattern:@"tasks/:key"
                                  method:RKRequestMethodGET]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Reward class]
                             pathPattern:@"tasks/:key"
                                  method:RKRequestMethodPUT]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Reward class]
                             pathPattern:@"tasks/user"
                                  method:RKRequestMethodPOST]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Reward class]
                             pathPattern:@"tasks/:key"
                                  method:RKRequestMethodDELETE]];

    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:rewardRequestMapping
                                                              objectClass:[Reward class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:rewardRequestMapping
                                                              objectClass:[Reward class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];

    RKDynamicMapping *dynamicTaskMapping = [RKDynamicMapping new];
    [dynamicTaskMapping
        setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
            if ([[representation valueForKey:@"type"] isEqualToString:@"reward"]) {
                return rewardMapping;
            } else {
                return taskMapping;
            }
        }];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:dynamicTaskMapping
                               method:RKRequestMethodGET
                          pathPattern:@"tasks/user"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:dynamicTaskMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"tasks/clearCompletedTodos"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:taskMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"tasks/:id/checklist/:checklistId/score"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher =
            [RKPathMatcher pathMatcherWithPattern:@"tasks/clearCompletedTodos"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type=='todo'"];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher =
        [RKPathMatcher pathMatcherWithPattern:@"content"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Customization"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"type=='background'"];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"tasks/user"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];

            HRPGURLParser *parser = [[HRPGURLParser alloc] initWithURLString:[URL absoluteString]];
            NSString *typeQuery = [parser valueForVariable:@"type"];
            if (typeQuery) {
                if ([typeQuery isEqualToString:@"habits"]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == 'habit'"]];
                }else if ([typeQuery isEqualToString:@"dailys"]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == 'daily'"]];
                } else if ([typeQuery isEqualToString:@"todos"]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == 'todo' && completed == NO"]];
                } else if ([typeQuery isEqualToString:@"completedTodos"]) {
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"type == 'todo' && completed == YES"]];
                }
            } else {
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(type == 'todo' && completed == NO) || type != 'todo'"]];
            }
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"tasks/user"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Reward"];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"user"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"user"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:NO
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InboxMessage"];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"groups"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            if ([URL.query isEqualToString:@"type=guilds"]) {
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
                fetchRequest.predicate =
                    [NSPredicate predicateWithFormat:@"type=='guild' && isMember == true"];
                return fetchRequest;
            }
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"groups/:id/members"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"partyID == %@", argsDict[@"id"]];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"shops/:identifier"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match && ![argsDict[@"identifier"] isEqualToString:@"market-gear"]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ShopItem"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"category.shop.identifier == %@ && isSubscriberItem != YES", argsDict[@"identifier"]];
            return fetchRequest;
        }

        return nil;
    }];

    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"shops/:identifier"];

        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ShopCategory"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"shop.identifier == %@", argsDict[@"identifier"]];
            return fetchRequest;
        }

        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"challenges/user"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Challenge"];
            return fetchRequest;
        }
        
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"user/in-app-rewards"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InAppReward"];
            return fetchRequest;
        }
        
        return nil;
    }];
    
    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"user/inventory/buy"];
        
        NSDictionary *argsDict = nil;
        BOOL match = [pathMatcher matchesPath:[URL relativePath]
                         tokenizeQueryStrings:YES
                              parsedArguments:&argsDict];
        if (match) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"InAppReward"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"key != 'armoire' && key != 'potion'"];
            return fetchRequest;
        }
        
        return nil;
    }];

    RKObjectMapping *upDownMapping = [RKObjectMapping mappingForClass:[HRPGTaskResponse class]];
    [upDownMapping addAttributeMappingsFromDictionary:@{
        @"delta" : @"delta",
        @"gp" : @"gold",
        @"lvl" : @"level",
        @"hp" : @"health",
        @"mp" : @"magic",
        @"exp" : @"experience",
        @"_tmp.drop.key" : @"dropKey",
        @"_tmp.drop.type" : @"dropType",
        @"_tmp.drop.dialog" : @"dropNote",
        @"_tmp.quest.progressDelta" : @"questDamage"
    }];
    [upDownMapping setAssignsDefaultValueForMissingAttributes:NO];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:upDownMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"tasks/:id/score/:direction"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *loginMapping = [RKObjectMapping mappingForClass:[HRPGLoginData class]];
    [loginMapping addAttributeMappingsFromDictionary:@{ @"id" : @"id", @"apiToken" : @"key" }];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:loginMapping
                               method:RKRequestMethodAny
                          pathPattern:@"user/auth/local/login"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:loginMapping
                               method:RKRequestMethodAny
                          pathPattern:@"user/auth/social"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:loginMapping
                               method:RKRequestMethodAny
                          pathPattern:@"user/auth/local/register"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *emptyMapping = [RKObjectMapping mappingForClass:[NSDictionary class]];
    [emptyMapping addAttributeMappingsFromDictionary:@{}];
    [RKMIMETypeSerialization registerClass:[HRPGEmptySerializer class] forMIMEType:@"text/plain"];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:emptyMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/sleep"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *gemPurchaseMapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [gemPurchaseMapping addAttributeMappingsFromDictionary:@{
        @"ok" : @"ok",
        @"data.message" : @"message"
    }];
    [RKMIMETypeSerialization registerClass:[HRPGEmptySerializer class] forMIMEType:@"text/plain"];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:gemPurchaseMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"iap/ios/verify"
                              keyPath:nil
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *emptyStringMapping = [RKObjectMapping mappingForClass:[NSString class]];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:emptyStringMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/chat/seen"
                              keyPath:nil
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:emptyStringMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"user/mark-pms-read"
                          keyPath:nil
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *feedMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [feedMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"value"]];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:feedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/feed/:pet/:food"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *entityMapping =
        [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
        @"_id" : @"id",
        @"balance" : @"balance",
        @"profile.name" : @"username",
        @"profile.photourl" : @"photoUrl",
        @"profile.blurb" : @"blurb",
        @"auth.local.email" : @"email",
        @"auth.local.username" : @"loginname",
        @"stats.lvl" : @"level",
        @"stats.gp" : @"gold",
        @"stats.exp" : @"experience",
        @"stats.mp" : @"magic",
        @"stats.hp" : @"health",
        @"stats.class" : @"hclass",
        @"items.currentPet" : @"currentPet",
        @"items.currentMount" : @"currentMount",
        @"auth.timestamps.loggedin" : @"lastLogin",
        @"auth.facebook.id": @"facebookID",
        @"auth.google.id" : @"googleID",
        @"stats.con" : @"constitution",
        @"stats.int" : @"intelligence",
        @"stats.per" : @"perception",
        @"stats.str" : @"strength",
        @"stats.training.con" : @"trainingConstitution",
        @"stats.training.int" : @"trainingIntelligence",
        @"stats.training.per" : @"trainingPerception",
        @"stats.training.str" : @"trainingStrength",
        @"stats.points" : @"pointsToAllocate",
        @"contributor.level" : @"contributorLevel",
        @"contributor.text" : @"contributorText",
        @"contributor.contributions" : @"contributions",
        @"party.order" : @"partyOrder",
        @"party._id" : @"partyID",
        @"party.quest.progress.up" : @"pendingDamage",
        @"items.pets" : @"petCountArray",
        @"purchased" : @"customizationsDictionary",
        @"invitations.party.id" : @"invitedParty",
        @"invitations.party.name" : @"invitedPartyName",
        @"inbox.optOut" : @"inboxOptOut",
        @"inbox.newMessages" : @"inboxNewMessages",
        @"challenges" : @"challengeArray",
        @"lastCron": @"lastCron",
        @"needsCron": @"needsCron",
        @"loginIncentives": @"loginIncentives"
    }];
    entityMapping.identificationAttributes = @[ @"id" ];
    RKEntityMapping *userTagMapping =
        [RKEntityMapping mappingForEntityForName:@"Tag" inManagedObjectStore:managedObjectStore];
    [userTagMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"id",
        @"name" : @"name",
        @"challenge" : @"challenge",
        @"@metadata.mapping.collectionIndex" : @"order"
    }];
    userTagMapping.identificationAttributes = @[ @"id" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tags"
                                                                       toKeyPath:@"tags"
                                                                     withMapping:userTagMapping]];
    
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:userTagMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"tags"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:userTagMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"tags/:id"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *tagRequestMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [tagRequestMapping addAttributeMappingsFromDictionary:@{
                                                         @"id" : @"id",
                                                         @"name" : @"name",
                                                         @"challenge" : @"challenge",
                                                         }];
    
    [[RKObjectManager sharedManager].router.routeSet
     addRoute:[RKRoute routeWithClass:[Tag class]
                          pathPattern:@"tags/:id"
                               method:RKRequestMethodPUT]];
    [[RKObjectManager sharedManager].router.routeSet
     addRoute:[RKRoute routeWithClass:[Tag class]
                          pathPattern:@"tags"
                               method:RKRequestMethodPOST]];
    [[RKObjectManager sharedManager].router.routeSet
     addRoute:[RKRoute routeWithClass:[Tag class]
                          pathPattern:@"tags/:id"
                               method:RKRequestMethodDELETE]];
    
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:tagRequestMapping
                                                              objectClass:[Tag class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:tagRequestMapping
                                                              objectClass:[Tag class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];
    
    RKEntityMapping *userOutfitMapping =
        [RKEntityMapping mappingForEntityForName:@"Outfit" inManagedObjectStore:managedObjectStore];
    [userOutfitMapping addAttributeMappingsFromDictionary:@{
        @"@parent.@parent.@parent._id" : @"userID",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    [userOutfitMapping addAttributeMappingsFromArray:@[
        @"armor", @"back", @"body", @"eyewear", @"head", @"headAccessory", @"shield", @"weapon"
    ]];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.gear.costume"
                                                               toKeyPath:@"costume"
                                                             withMapping:userOutfitMapping]];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.gear.equipped"
                                                               toKeyPath:@"equipped"
                                                             withMapping:userOutfitMapping]];

    RKEntityMapping *preferencesMapping =
        [RKEntityMapping mappingForEntityForName:@"Preferences"
                            inManagedObjectStore:managedObjectStore];
    [preferencesMapping addAttributeMappingsFromDictionary:@{
        @"@parent._id" : @"userID",
        @"allocationMode" : @"allocationMode",
        @"dayStart" : @"dayStart",
        @"disableClasses" : @"disableClass",
        @"sleep" : @"sleep",
        @"skin" : @"skin",
        @"size" : @"size",
        @"shirt" : @"shirt",
        @"hair.mustache" : @"hairMustache",
        @"hair.bangs" : @"hairBangs",
        @"hair.beard" : @"hairBeard",
        @"hair.base" : @"hairBase",
        @"hair.color" : @"hairColor",
        @"hair.flower" : @"hairFlower",
        @"background" : @"background",
        @"costume" : @"useCostume",
        @"language" : @"language",
        @"timezoneOffset" : @"timezoneOffset",
        @"chair": @"chair"
    }];
    preferencesMapping.identificationAttributes = @[ @"userID" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"preferences"
                                                               toKeyPath:@"preferences"
                                                             withMapping:preferencesMapping]];
    
    RKEntityMapping *subscriptionMapping = [RKEntityMapping mappingForEntityForName:@"SubscriptionPlan" inManagedObjectStore:managedObjectStore];
    [subscriptionMapping addAttributeMappingsFromDictionary:@{
                                                              @"customerId": @"customerId",
                                                              @"dateCreated": @"dateCreated",
                                                              @"dateTerminated": @"dateTerminated",
                                                              @"planId": @"planId",
                                                              @"paymentMethod": @"paymentMethod",
                                                              @"consecutive.trinkets": @"consecutiveTrinkets",
                                                              @"consecutive.gemCapExtra": @"gemCapExtra",
                                                              @"gemsBought": @"gemsBought",
                                                              @"mysteryItems": @"mysteryItemsArray",
                                                              @"automaticAllocation": @"automaticAllocation",
                                                              }];
    subscriptionMapping.identificationAttributes = @[ @"customerId" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"purchased.plan" toKeyPath:@"subscriptionPlan" withMapping:subscriptionMapping]];

    RKEntityMapping *improvementCategoryMapping =
        [RKEntityMapping mappingForEntityForName:@"ImprovementCategory"
                            inManagedObjectStore:managedObjectStore];
    [improvementCategoryMapping
        addAttributeMappingFromKeyOfRepresentationToAttribute:@"identifier"];
    [improvementCategoryMapping addAttributeMappingsFromDictionary:@{
        @"{identifier}" : @"isActive"
    }];
    improvementCategoryMapping.identificationAttributes = @[ @"identifier" ];
    [preferencesMapping
        addPropertyMapping:[RKRelationshipMapping
                               relationshipMappingFromKeyPath:@"improvementCategories"
                                                    toKeyPath:@"improvementCategories"
                                                  withMapping:improvementCategoryMapping]];

    RKEntityMapping *pushNotificationsMapping = [RKEntityMapping mappingForEntityForName:@"PushNotifications" inManagedObjectStore:managedObjectStore];
    [pushNotificationsMapping addAttributeMappingsFromArray:@[
                                                              @"giftedGems",
                                                              @"giftedSubscription",
                                                              @"invitedGuild",
                                                              @"invitedParty",
                                                              @"invitedQuest",
                                                              @"newPM",
                                                              @"questStarted",
                                                              @"wonChallenge",
                                                              @"unsubscribeFromAll"
                                                              ]];
    [pushNotificationsMapping addAttributeMappingsFromDictionary:@{@"@parent.@parent._id" : @"userID"}];
    [preferencesMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"pushNotifications" toKeyPath:@"pushNotifications" withMapping:pushNotificationsMapping]];

    RKEntityMapping *flagsMapping =
        [RKEntityMapping mappingForEntityForName:@"Flags" inManagedObjectStore:managedObjectStore];
    [flagsMapping addAttributeMappingsFromDictionary:@{
        @"@parent._id" : @"userID",
        @"newStuff" : @"habitNewStuff",
        @"dropsEnabled" : @"dropsEnabled",
        @"itemsEnabled" : @"itemsEnabled",
        @"classSelected" : @"classSelected",
        @"armoireEnabled" : @"armoireEnabled",
        @"armoireEmpty" : @"armoireEmpty",
        @"communityGuidelinesAccepted" : @"communityGuidelinesAccepted",
    }];
    flagsMapping.identificationAttributes = @[ @"userID" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"flags"
                                                                       toKeyPath:@"flags"
                                                                     withMapping:flagsMapping]];

    RKEntityMapping *buffMapping =
    [RKEntityMapping mappingForEntityForName:@"Buff" inManagedObjectStore:managedObjectStore];
    [buffMapping addAttributeMappingsFromDictionary:@{
                                                      @"@parent.@parent._id" : @"userID",
                                                      @"int" : @"intelligence",
                                                      @"str" : @"strength",
                                                      @"per" : @"perception",
                                                      @"con" : @"constitution",
                                                      @"spookySparkles" : @"spookySparkles",
                                                      @"seafoam" : @"seafoam",
                                                      @"snowball" : @"snowball",
                                                      @"shinySeed" : @"shinySeed",
                                                      @"streak" : @"streak",
                                                      }];
    buffMapping.identificationAttributes = @[ @"userID" ];
    [entityMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats.buffs"
                                                                    toKeyPath:@"buff"
                                                                  withMapping:buffMapping]];

    RKEntityMapping *specialItemsMapping =
    [RKEntityMapping mappingForEntityForName:@"SpecialItems" inManagedObjectStore:managedObjectStore];
    [specialItemsMapping addAttributeMappingsFromDictionary:@{
                                                      @"@parent.@parent._id" : @"userID",
                                                      @"spookySparkles" : @"spookySparkles",
                                                      @"seafoam" : @"seafoam",
                                                      @"snowball" : @"snowball",
                                                      @"shinySeed" : @"shinySeed",
                                                      @"valentine" : @"valentine",
                                                      @"nye" : @"nye",
                                                      @"greeting" : @"greeting",
                                                      @"thankyou" : @"thankyou",
                                                      @"birthday" : @"birthday"
                                                      }];
    specialItemsMapping.identificationAttributes = @[ @"userID" ];
    [entityMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.special"
                                                                    toKeyPath:@"specialItems"
                                                                  withMapping:specialItemsMapping]];
    
    RKEntityMapping *gearOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Gear" inManagedObjectStore:managedObjectStore];
    gearOwnedMapping.forceCollectionMapping = YES;
    [gearOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [gearOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"owned" }];
    gearOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.gear.owned"
                                                                       toKeyPath:@"ownedGear"
                                                                     withMapping:gearOwnedMapping]];

    RKEntityMapping *questOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Quest" inManagedObjectStore:managedObjectStore];
    questOwnedMapping.forceCollectionMapping = YES;
    [questOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [questOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"owned" }];
    questOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.quests"
                                                               toKeyPath:@"ownedQuests"
                                                             withMapping:questOwnedMapping]];

    RKEntityMapping *foodOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Food" inManagedObjectStore:managedObjectStore];
    foodOwnedMapping.forceCollectionMapping = YES;
    [foodOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [foodOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"owned" }];
    foodOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.food"
                                                                       toKeyPath:@"ownedFood"
                                                                     withMapping:foodOwnedMapping]];

    RKEntityMapping *hPotionOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"HatchingPotion"
                            inManagedObjectStore:managedObjectStore];
    hPotionOwnedMapping.forceCollectionMapping = YES;
    [hPotionOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [hPotionOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"owned" }];
    hPotionOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.hatchingPotions"
                                                               toKeyPath:@"ownedHatchingPotions"
                                                             withMapping:hPotionOwnedMapping]];

    RKEntityMapping *eggOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Egg" inManagedObjectStore:managedObjectStore];
    eggOwnedMapping.forceCollectionMapping = YES;
    [eggOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [eggOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"owned" }];
    eggOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.eggs"
                                                                       toKeyPath:@"ownedEggs"
                                                                     withMapping:eggOwnedMapping]];

    RKEntityMapping *petOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Pet" inManagedObjectStore:managedObjectStore];
    petOwnedMapping.forceCollectionMapping = YES;
    [petOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [petOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"trained" }];
    petOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.pets"
                                                                       toKeyPath:@"ownedPets"
                                                                     withMapping:petOwnedMapping]];

    RKEntityMapping *mountOwnedMapping =
        [RKEntityMapping mappingForEntityForName:@"Pet" inManagedObjectStore:managedObjectStore];
    mountOwnedMapping.forceCollectionMapping = YES;
    [mountOwnedMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [mountOwnedMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"asMount" }];
    mountOwnedMapping.identificationAttributes = @[ @"key" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.mounts"
                                                               toKeyPath:@"ownedMounts"
                                                             withMapping:mountOwnedMapping]];

    RKEntityMapping *newMessageMapping =
        [RKEntityMapping mappingForEntityForName:@"Group" inManagedObjectStore:managedObjectStore];
    newMessageMapping.forceCollectionMapping = YES;
    [newMessageMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"id"];
    [newMessageMapping addAttributeMappingsFromDictionary:@{ @"(id).value" : @"unreadMessages" }];
    newMessageMapping.identificationAttributes = @[ @"id" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"newMessages"
                                                               toKeyPath:@"groups"
                                                             withMapping:newMessageMapping]];

    RKEntityMapping *tutorialsSeenMapping =
        [RKEntityMapping mappingForEntityForName:@"TutorialSteps"
                            inManagedObjectStore:managedObjectStore];
    tutorialsSeenMapping.forceCollectionMapping = YES;
    [tutorialsSeenMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"identifier"];
    [tutorialsSeenMapping addAttributeMappingsFromDictionary:@{
        @"(identifier)" : @"wasShown",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    tutorialsSeenMapping.identificationAttributes = @[ @"identifier" ];
    [flagsMapping addPropertyMapping:[RKRelationshipMapping
                                         relationshipMappingFromKeyPath:@"tutorial.ios"
                                                              toKeyPath:@"iOSTutorialSteps"
                                                            withMapping:tutorialsSeenMapping]];
    [flagsMapping addPropertyMapping:[RKRelationshipMapping
                                         relationshipMappingFromKeyPath:@"tutorial.common"
                                                              toKeyPath:@"commonTutorialSteps"
                                                            withMapping:tutorialsSeenMapping]];

    RKEntityMapping *taskOrderMapping = [RKEntityMapping mappingForEntityForName:@"Task" inManagedObjectStore:managedObjectStore];
    [taskOrderMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"id"]];
    [taskOrderMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex" toKeyPath:@"order"]];
    taskOrderMapping.identificationAttributes = @[ @"id" ];

    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:taskOrderMapping
                          method:RKRequestMethodAny
                          pathPattern:@"user"
                          keyPath:@"data.tasksOrder.habits"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:taskOrderMapping
                          method:RKRequestMethodAny
                          pathPattern:@"user"
                          keyPath:@"data.tasksOrder.todos"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:taskOrderMapping
                          method:RKRequestMethodAny
                          pathPattern:@"user"
                          keyPath:@"data.tasksOrder.dailys"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:taskOrderMapping
                          method:RKRequestMethodAny
                          pathPattern:@"tasks/:id/move/to/:pos"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *inboxMessageMapping = [RKEntityMapping mappingForEntityForName:@"InboxMessage"
                                                       inManagedObjectStore:managedObjectStore];
    [inboxMessageMapping setForceCollectionMapping:YES];
    [inboxMessageMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"id"];
    [inboxMessageMapping setIdentificationAttributes:@[@"id"]];
    [inboxMessageMapping addAttributeMappingsFromDictionary:@{
                                                      @"(id).text" : @"text",
                                                      @"(id).timestamp" : @"timestamp",
                                                      @"(id).user" : @"username",
                                                      @"(id).uuid" : @"userID",
                                                      @"(id).sent" : @"sent",
                                                      @"(id).contributor.level" : @"contributorLevel",
                                                      @"(id).contributor.text" : @"contributorText",
                                                      @"(id).backer.tier" : @"backerLevel",
                                                      @"(id).backer.npc" : @"backerNpc",
                                                      @"(id).sort" : @"sort"
                                                      }];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                       relationshipMappingFromKeyPath:@"inbox.messages"
                                       toKeyPath:@"inboxMessages"
                                       withMapping:inboxMessageMapping]];

    RKEntityMapping *pushDeviceMapping = [RKEntityMapping mappingForEntityForName:@"PushDevice"
                                                               inManagedObjectStore:managedObjectStore];
    [pushDeviceMapping setIdentificationAttributes:@[@"regId"]];
    [pushDeviceMapping addAttributeMappingsFromDictionary:@{
                                                              @"regId" : @"regId",
                                                              @"type" : @"type"
                                                              }];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                       relationshipMappingFromKeyPath:@"pushDevices"
                                       toKeyPath:@"pushDevices"
                                       withMapping:pushDeviceMapping]];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/class/cast/:spell"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/revive"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/change-class"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/disable-classes"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/unlock"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/purchase/:type/:item"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *equipMapping = [RKObjectMapping mappingForClass:[HRPGUserBuyResponse class]];
    [equipMapping addAttributeMappingsFromDictionary:@{
        @"gear.equipped.headAccessory" : @"equippedHeadAccessory",
        @"gear.equipped.armor" : @"equippedArmor",
        @"gear.equipped.body" : @"equippedBody",
        @"gear.equipped.eyewear" : @"equippedEyewear",
        @"gear.equipped.head" : @"equippedHead",
        @"gear.equipped.shield" : @"equippedShield",
        @"gear.equipped.weapon" : @"equippedWeapon",
        @"gear.equipped.back" : @"equippedBack",
        @"gear.costume.headAccessory" : @"costumeHeadAccessory",
        @"gear.costume.armor" : @"costumeArmor",
        @"gear.costume.back" : @"costumeBack",
        @"gear.costume.body" : @"costumeBody",
        @"gear.costume.eyewear" : @"costumeEyewear",
        @"gear.costume.head" : @"costumeHead",
        @"gear.costume.shield" : @"costumeShield",
        @"gear.costume.weapon" : @"costumeWeapon",
        @"currentPet" : @"currentPet",
        @"currentMount" : @"currentMount",
    }];
    equipMapping.assignsDefaultValueForMissingAttributes = NO;
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:equipMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/equip/:type/:key"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:eggOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/equip/:type/:key"
                              keyPath:@"data.eggs"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:petOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/equip/:type/:key"
                              keyPath:@"data.pets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:hPotionOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/equip/:type/:key"
                              keyPath:@"data.hatchingPotions"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:equipMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/hatch/:egg/:hatchingPotion"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:eggOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/hatch/:egg/:hatchingPotion"
                              keyPath:@"data.eggs"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:petOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/hatch/:egg/:hatchingPotion"
                              keyPath:@"data.pets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:hPotionOwnedMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/hatch/:egg/:hatchingPotion"
                              keyPath:@"data.hatchingPotions"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    entityMapping.assignsDefaultValueForMissingAttributes = YES;

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPUT
                          pathPattern:@"user"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    [entityMapping addAttributeMappingsFromDictionary:@{
        @"stats.toNextLevel" : @"nextLevel",
        @"stats.maxHealth" : @"maxHealth",
        @"stats.maxMP" : @"maxMagic",
    }];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodGET
                          pathPattern:@"user"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];


    RKObjectMapping *buyMapping = [RKObjectMapping mappingForClass:[HRPGUserBuyResponse class]];
    [buyMapping addAttributeMappingsFromDictionary:@{
        @"lvl" : @"level",
        @"gp" : @"gold",
        @"exp" : @"experience",
        @"mp" : @"magic",
        @"hp" : @"health",
        @"items.gear.equipped.headAccessory" : @"equippedHeadAccessory",
        @"items.gear.equipped.armor" : @"equippedArmor",
        @"items.gear.equipped.back" : @"equippedBack",
        @"items.gear.equipped.body" : @"equippedBody",
        @"items.gear.equipped.eyewear" : @"equippedEyewear",
        @"items.gear.equipped.head" : @"equippedHead",
        @"items.gear.equipped.shield" : @"equippedShield",
        @"items.gear.equipped.weapon" : @"equippedWeapon",
        @"items.gear.costume.headAccessory" : @"costumeHeadAccessory",
        @"items.gear.costume.armor" : @"costumeArmor",
        @"items.gear.costume.back" : @"costumeBack",
        @"items.gear.costume.body" : @"costumeBody",
        @"items.gear.costume.eyewear" : @"costumeEyewear",
        @"items.gear.costume.head" : @"costumeHead",
        @"items.gear.costume.shield" : @"costumeShield",
        @"items.gear.costume.weapon" : @"costumeWeapon",
        @"items.currentPet" : @"currentPet",
        @"items.currentMount" : @"currentMount",
        @"armoire.type" : @"armoireType",
        @"armoire.dropKey" : @"armoireKey",
        @"armoire.dropArticle" : @"armoireArticle",
        @"armoire.dropText" : @"armoireText",
        @"armoire.value" : @"armoireValue",
    }];
    buyMapping.assignsDefaultValueForMissingAttributes = NO;
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:buyMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/buy/:key"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:buyMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"user/sell/:type/:key"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    [statsMapping addAttributeMappingsFromDictionary:@{
                                                       @"str": @"strength",
                                                       @"int": @"intelligence",
                                                       @"con": @"constitution",
                                                       @"per": @"perception",
                                                       @"points": @"points",
                                                       @"mp": @"mana"
                                                       }];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:statsMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"user/allocate"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:statsMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"user/allocate-bulk"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    
    entityMapping =
        [RKEntityMapping mappingForEntityForName:@"Group" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{
        @"_id" : @"id",
        @"name" : @"name",
        @"description" : @"hdescription",
        @"quest.key" : @"questKey",
        @"quest.progress.hp" : @"questHP",
        @"quest.progress.rage" : @"questRage",
        @"quest.active" : @"questActive",
        @"quest.leader" : @"questLeader",
        @"quest.extra.worldDmg": @"rageStrikes",
        @"privacy" : @"privacy",
        @"type" : @"type",
        @"memberCount" : @"memberCount",
        @"balance" : @"balance"
    }];
    entityMapping.identificationAttributes = @[ @"id" ];
    entityMapping.assignsDefaultValueForMissingAttributes = YES;
    RKEntityMapping *chatMapping = [RKEntityMapping mappingForEntityForName:@"ChatMessage"
                                                       inManagedObjectStore:managedObjectStore];
    [chatMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"id",
        @"text" : @"text",
        @"timestamp" : @"timestamp",
        @"user" : @"user",
        @"uuid" : @"uuid",
        @"contributor.level" : @"contributorLevel",
        @"contributor.text" : @"contributorText",
        @"backer.tier" : @"backerLevel",
        @"backer.npc" : @"backerNpc"
    }];
    RKEntityMapping *chatUserMapping =
        [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [chatUserMapping addAttributeMappingsFromDictionary:@{ @"uuid" : @"id" }];
    [chatMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                       toKeyPath:@"userObject"
                                                                     withMapping:chatUserMapping]];
    RKEntityMapping *likeMapping = [RKEntityMapping mappingForEntityForName:@"ChatMessageLike"
                                                       inManagedObjectStore:managedObjectStore];
    likeMapping.forceCollectionMapping = YES;
    [likeMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"userID"];
    likeMapping.identificationAttributes = @[ @"userID" ];
    [chatMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"likes"
                                                                       toKeyPath:@"likes"
                                                                     withMapping:likeMapping]];
    RKEntityMapping *flagMapping = [RKEntityMapping mappingForEntityForName:@"ChatMessageFlag"
                                                       inManagedObjectStore:managedObjectStore];
    flagMapping.forceCollectionMapping = YES;
    [flagMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"userID"];
    flagMapping.identificationAttributes = @[ @"userID" ];
    [chatMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"flags"
                                                                    toKeyPath:@"flags"
                                                                  withMapping:flagMapping]];
    RKEntityMapping *chatAvatarMapping = [RKEntityMapping mappingForEntityForName:@"ChatMessageAvatar"
                                                       inManagedObjectStore:managedObjectStore];
    [chatAvatarMapping addAttributeMappingsFromDictionary:@{
                                                     @"preferences.size": @"size",
                                                     @"preferences.shirt": @"shirt",
                                                     @"preferences.skin": @"skin",
                                                     @"preferences.background": @"background",
                                                     @"preferences.chair": @"chair",
                                                     @"preferences.hair.color": @"hairColor",
                                                     @"preferences.hair.bangs": @"hairBangs",
                                                     @"preferences.hair.base": @"hairBase",
                                                     @"preferences.hair.mustache": @"hairMustache",
                                                     @"preferences.hair.beard": @"hairBeard",
                                                     @"preferences.hair.flower": @"hairFlower",
                                                     @"preferences.costume": @"useCostume",
                                                     @"items.currentPet": @"currentPet",
                                                     @"items.currentMount": @"currentMount"
                                                     }];
    [chatAvatarMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.gear.equipped" toKeyPath:@"equipped" withMapping:userOutfitMapping]];
    [chatAvatarMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items.gear.costume" toKeyPath:@"costume" withMapping:userOutfitMapping]];
    [chatMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"userStyles"
                                                                    toKeyPath:@"avatar"
                                                                  withMapping:chatAvatarMapping]];
    [entityMapping
        addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"chat"
                                                                       toKeyPath:@"chatmessages"
                                                                     withMapping:chatMapping]];
    chatMapping.identificationAttributes = @[ @"id" ];
    RKEntityMapping *collectMapping = [RKEntityMapping mappingForEntityForName:@"QuestCollect"
                                                          inManagedObjectStore:managedObjectStore];
    collectMapping.forceCollectionMapping = YES;
    [collectMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [collectMapping addAttributeMappingsFromDictionary:@{ @"(key)" : @"collectCount" }];
    collectMapping.identificationAttributes = @[ @"key" ];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"quest.progress.collect"
                                                               toKeyPath:@"collectStatus"
                                                             withMapping:collectMapping]];
    RKEntityMapping *questParticipantsMapping =
        [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    questParticipantsMapping.forceCollectionMapping = YES;
    [questParticipantsMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"id"];
    [questParticipantsMapping addAttributeMappingsFromDictionary:@{
        @"(id)" : @"participateInQuest"
    }];
    questParticipantsMapping.identificationAttributes = @[ @"id" ];
    questParticipantsMapping.assignsDefaultValueForMissingAttributes = YES;
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"quest.members"
                                                               toKeyPath:@"questParticipants"
                                                             withMapping:questParticipantsMapping]];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/accept"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/reject"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/abort"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/invite/:questKey"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/force-start"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/quests/cancel"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:emptyMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/invite"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/join"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/leave"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *groupRequestMapping =
        [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
    [groupRequestMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"_id",
        @"name" : @"name",
        @"hdescription" : @"description",
        @"type" : @"type",
        @"leader.id" : @"leader"
    }];

    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Group class]
                             pathPattern:@"groups/:id"
                                  method:RKRequestMethodGET]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Group class]
                             pathPattern:@"groups/:id"
                                  method:RKRequestMethodPUT]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Group class]
                             pathPattern:@"groups"
                                  method:RKRequestMethodPOST]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[Group class]
                             pathPattern:@"groups/:id"
                                  method:RKRequestMethodDELETE]];

    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:groupRequestMapping
                                                              objectClass:[Group class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPOST];
    [objectManager addRequestDescriptor:requestDescriptor];
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:groupRequestMapping
                                                              objectClass:[Group class]
                                                              rootKeyPath:nil
                                                                   method:RKRequestMethodPUT];
    [objectManager addRequestDescriptor:requestDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:chatMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/chat"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:chatMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/chat/:key/like"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:chatMapping
                               method:RKRequestMethodPOST
                          pathPattern:@"groups/:id/chat/:key/flag"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:chatMapping
                               method:RKRequestMethodDELETE
                          pathPattern:@"groups/:id/chat/:key"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[ChatMessage class]
                             pathPattern:@"groups/:group.id/chat"
                                  method:RKRequestMethodPOST]];
    [[RKObjectManager sharedManager].router.routeSet
        addRoute:[RKRoute routeWithClass:[ChatMessage class]
                             pathPattern:@"groups/:group.id/chat/:id"
                                  method:RKRequestMethodDELETE]];

    RKEntityMapping *memberMapping =
        [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [memberMapping addAttributeMappingsFromDictionary:@{
        @"_id" : @"id",
        @"profile.name" : @"username",
        @"profile.blurb" : @"blurb",
        @"stats.lvl" : @"level",
        @"stats.gp" : @"gold",
        @"stats.exp" : @"experience",
        @"stats.mp" : @"magic",
        @"stats.hp" : @"health",
        @"stats.toNextLevel" : @"nextLevel",
        @"stats.maxHealth" : @"maxHealth",
        @"stats.maxMP" : @"maxMagic",
        @"stats.class" : @"hclass",
        @"items.currentPet" : @"currentPet",
        @"items.currentMount" : @"currentMount",
        @"auth.timestamps.loggedin" : @"lastLogin",
        @"auth.timestamps.created" : @"memberSince",
        @"stats.con" : @"constitution",
        @"stats.int" : @"intelligence",
        @"stats.per" : @"perception",
        @"stats.str" : @"strength",
        @"stats.training.con" : @"trainingConstitution",
        @"stats.training.int" : @"trainingIntelligence",
        @"stats.training.per" : @"trainingPerception",
        @"stats.training.str" : @"trainingStrength",
        @"contributor.level" : @"contributorLevel",
        @"contributor.text" : @"contributorText",
        @"@metadata.mapping.collectionIndex" : @"partyPosition",
        @"party.order" : @"partyOrder",
        @"party._id" : @"partyID",
        @"items.pets" : @"petCountArray"
    }];
    memberMapping.identificationAttributes = @[ @"id" ];

    [memberMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.gear.costume"
                                                               toKeyPath:@"costume"
                                                             withMapping:userOutfitMapping]];
    [memberMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"items.gear.equipped"
                                                               toKeyPath:@"equipped"
                                                             withMapping:userOutfitMapping]];

    [memberMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"preferences"
                                                               toKeyPath:@"preferences"
                                                             withMapping:preferencesMapping]];
    
    [memberMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats.buffs"
                                                                    toKeyPath:@"buff"
                                                                  withMapping:buffMapping]];

    RKEntityMapping *memberIdMapping =
        [RKEntityMapping mappingForEntityForName:@"User" inManagedObjectStore:managedObjectStore];
    [memberIdMapping
        addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"id"]];
    memberIdMapping.identificationAttributes = @[ @"id" ];
    RKDynamicMapping *dynamicMemberMapping = [RKDynamicMapping new];
    [dynamicMemberMapping
        setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
            if ([representation isKindOfClass:[NSString class]]) {
                return memberIdMapping;
            }
            return memberMapping;
        }];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:memberMapping
                               method:RKRequestMethodAny
                          pathPattern:@"groups/:id/members"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    [entityMapping addPropertyMapping:[RKRelationshipMapping
                                          relationshipMappingFromKeyPath:@"leader"
                                                               toKeyPath:@"leader"
                                                             withMapping:dynamicMemberMapping]];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodAny
                          pathPattern:@"groups/:id"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:entityMapping
                               method:RKRequestMethodAny
                          pathPattern:@"groups"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:memberMapping
                               method:RKRequestMethodGET
                          pathPattern:@"members/:id"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *gearMapping =
        [RKEntityMapping mappingForEntityForName:@"Gear" inManagedObjectStore:managedObjectStore];
    gearMapping.forceCollectionMapping = YES;
    [gearMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [gearMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).notes" : @"notes",
        @"(key).con" : @"con",
        @"(key).value" : @"value",
        @"(key).type" : @"type",
        @"(key).klass" : @"klass",
        @"(key).index" : @"index",
        @"(key).str" : @"str",
        @"(key).int" : @"intelligence",
        @"(key).per" : @"per",
        @"(key).event.start" : @"eventStart",
        @"(key).event.end" : @"eventEnd",
        @"(key).specialClass" : @"specialClass",
        @"(key).gearSet" : @"set"
    }];
    gearMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:gearMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.gear.flat"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKEntityMapping *potionMapping =
    [RKEntityMapping mappingForEntityForName:@"InAppReward" inManagedObjectStore:managedObjectStore];
    [potionMapping addAttributeMappingsFromDictionary:@{
                                                        @"text" : @"text",
                                                        @"key" : @"key",
                                                        @"value" : @"value",
                                                        @"notes" : @"notes",
                                                        }];
    potionMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:potionMapping
                          method:RKRequestMethodGET
                          pathPattern:@"content"
                          keyPath:@"data.potion"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    RKEntityMapping *armoireMapping = [RKEntityMapping mappingForEntityForName:@"InAppReward"
                                                          inManagedObjectStore:managedObjectStore];
    [armoireMapping addAttributeMappingsFromDictionary:@{
                                                         @"text" : @"text",
                                                         @"key" : @"key",
                                                         @"value" : @"value",
                                                         @"notes" : @"notes",
                                                         }];
    armoireMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:armoireMapping
                          method:RKRequestMethodGET
                          pathPattern:@"content"
                          keyPath:@"data.armoire"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *inAppRewardsMapping =
        [RKEntityMapping mappingForEntityForName:@"InAppReward" inManagedObjectStore:managedObjectStore];
    [inAppRewardsMapping addAttributeMappingsFromArray:@[
        @"key",
        @"text",
        @"notes",
        @"pinType",
        @"purchaseType",
        @"isSuggested",
        @"locked",
        @"value",
        @"currency",
        @"path"
    ]];
    [inAppRewardsMapping addAttributeMappingsFromDictionary:@{
                                                              @"class": @"imageName",
                                                              @"@metadata.mapping.collectionIndex": @"order",
                                                              @"event.end": @"availableUntil",
                                                              }];
    inAppRewardsMapping.identificationAttributes = @[ @"key" ];
    inAppRewardsMapping.assignsDefaultValueForMissingAttributes = NO;
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:inAppRewardsMapping
                               method:RKRequestMethodGET
                          pathPattern:@"user/in-app-rewards"
                              keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:inAppRewardsMapping
                          method:RKRequestMethodGET
                          pathPattern:@"user/inventory/buy"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKEntityMapping *singleGearMapping =
    [RKEntityMapping mappingForEntityForName:@"Gear" inManagedObjectStore:managedObjectStore];
    [singleGearMapping addAttributeMappingsFromDictionary:@{
                                                            @"key": @"key",
                                                            @"text" : @"text",
                                                            @"notes" : @"notes",
                                                            @"con" : @"con",
                                                            @"value" : @"value",
                                                            @"type" : @"type",
                                                            @"klass" : @"klass",
                                                            @"index" : @"index",
                                                            @"str" : @"str",
                                                            @"int" : @"intelligence",
                                                            @"per" : @"per",
                                                            @"event.start" : @"eventStart",
                                                            @"event.end" : @"eventEnd",
                                                            @"specialClass" : @"specialClass",
                                                            @"gearSet" : @"set"
                                                            }];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:singleGearMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"user/open-mystery-item"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *eggMapping =
        [RKEntityMapping mappingForEntityForName:@"Egg" inManagedObjectStore:managedObjectStore];
    eggMapping.forceCollectionMapping = YES;
    [eggMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [eggMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).adjective" : @"adjective",
        @"(key).canBuy" : @"canBuy",
        @"(key).value" : @"value",
        @"(key).notes" : @"notes",
        @"(key).mountText" : @"mountText",
        @"(key).dialog" : @"dialog",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    eggMapping.identificationAttributes = @[ @"key" ];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:eggMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.eggs"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    RKEntityMapping *hatchingPotionMapping =
        [RKEntityMapping mappingForEntityForName:@"HatchingPotion"
                            inManagedObjectStore:managedObjectStore];
    hatchingPotionMapping.forceCollectionMapping = YES;
    [hatchingPotionMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [hatchingPotionMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).value" : @"value",
        @"(key).notes" : @"notes",
        @"(key).dialog" : @"dialog",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    hatchingPotionMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:hatchingPotionMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.hatchingPotions"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    RKEntityMapping *foodMapping =
        [RKEntityMapping mappingForEntityForName:@"Food" inManagedObjectStore:managedObjectStore];
    foodMapping.forceCollectionMapping = YES;
    [foodMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [foodMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).target" : @"target",
        @"(key).canBuy" : @"canBuy",
        @"(key).value" : @"value",
        @"(key).notes" : @"notes",
        @"(key).article" : @"article",
        @"(key).dialog" : @"dialog",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    foodMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:foodMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.food"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    RKEntityMapping *spellMapping =
        [RKEntityMapping mappingForEntityForName:@"Spell" inManagedObjectStore:managedObjectStore];
    spellMapping.forceCollectionMapping = YES;
    [spellMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [spellMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).lvl" : @"level",
        @"(key).notes" : @"notes",
        @"(key).mana" : @"mana",
        @"(key).target" : @"target",
        @"@metadata.mapping.rootKeyPath" : @"klass"
    }];
    spellMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:spellMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.spells.healer"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:spellMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.spells.wizard"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:spellMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.spells.warrior"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:spellMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.spells.rogue"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:spellMapping
                          method:RKRequestMethodGET
                          pathPattern:@"content"
                          keyPath:@"data.spells.special"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *questMapping =
        [RKEntityMapping mappingForEntityForName:@"Quest" inManagedObjectStore:managedObjectStore];
    questMapping.forceCollectionMapping = YES;
    [questMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    RKEntityMapping *questCollectMapping =
        [RKEntityMapping mappingForEntityForName:@"QuestCollect"
                            inManagedObjectStore:managedObjectStore];
    questCollectMapping.forceCollectionMapping = YES;
    [questCollectMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [questCollectMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).count" : @"count"
    }];
    questCollectMapping.identificationAttributes = @[ @"key" ];
    [questMapping addPropertyMapping:[RKRelationshipMapping
                                         relationshipMappingFromKeyPath:@"(key).collect"
                                                              toKeyPath:@"collect"
                                                            withMapping:questCollectMapping]];
    RKEntityMapping *questItemsMapping =
    [RKEntityMapping mappingForEntityForName:@"QuestReward"
                        inManagedObjectStore:managedObjectStore];
    questItemsMapping.forceCollectionMapping = YES;
    [questItemsMapping addAttributeMappingsFromArray:@[
                                                       @"text",
                                                       @"type",
                                                       @"key",
                                                       @"onlyOwner"]];
    questItemsMapping.identificationAttributes = @[ @"key" ];
    [questMapping addPropertyMapping:[RKRelationshipMapping
                                      relationshipMappingFromKeyPath:@"(key).drop.items"
                                      toKeyPath:@"itemDrops"
                                      withMapping:questItemsMapping]];
    [questMapping addAttributeMappingsFromDictionary:@{
        @"(key).text" : @"text",
        @"(key).completition" : @"completition",
        @"(key).canBuy" : @"canBuy",
        @"(key).value" : @"value",
        @"(key).notes" : @"notes",
        @"(key).drop.gp" : @"dropGp",
        @"(key).drop.exp" : @"dropExp",
        @"(key).boss.name" : @"bossName",
        @"(key).boss.hp" : @"bossHp",
        @"(key).boss.str" : @"bossStr",
        @"(key).boss.def" : @"bossDef",
        @"(key).boss.rage.title" : @"rageTitle",
        @"(key).boss.rage.value" : @"bossRage",
        @"(key).boss.rage.description" : @"rageDescription",
        @"(key).colors.dark": @"colorDark",
        @"(key).colors.medium": @"colorMedium",
        @"(key).colors.light": @"colorLight",
        @"(key).colors.extralight": @"colorExtraLight",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    questMapping.identificationAttributes = @[ @"key" ];

    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:questMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.quests"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *backgroundMapping =
        [RKEntityMapping mappingForEntityForName:@"Customization"
                            inManagedObjectStore:managedObjectStore];
    backgroundMapping.forceCollectionMapping = YES;
    [backgroundMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"name"];
    [backgroundMapping addAttributeMappingsFromDictionary:@{
        @"(name).text" : @"text",
        @"(name).notes" : @"notes",
        @"(name).set.key" : @"set",
        @"(name).price" : @"price",
        @"@metadata.mapping.rootKeyPath" : @"type"
    }];
    backgroundMapping.identificationAttributes = @[ @"name" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:backgroundMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.appearances.background"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *petMapping =
        [RKEntityMapping mappingForEntityForName:@"Pet" inManagedObjectStore:managedObjectStore];
    petMapping.forceCollectionMapping = YES;
    [petMapping addAttributeMappingFromKeyOfRepresentationToAttribute:@"key"];
    [petMapping addAttributeMappingsFromDictionary:@{ @"@metadata.mapping.rootKeyPath" : @"type" }];
    petMapping.identificationAttributes = @[ @"key" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:petMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.pets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:petMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.questPets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:petMapping
                          method:RKRequestMethodGET
                          pathPattern:@"content"
                          keyPath:@"data.specialPets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:petMapping
                          method:RKRequestMethodGET
                          pathPattern:@"content"
                          keyPath:@"data.premiumPets"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKEntityMapping *faqMapping =
        [RKEntityMapping mappingForEntityForName:@"FAQ" inManagedObjectStore:managedObjectStore];
    [faqMapping addAttributeMappingsFromDictionary:@{
        @"question" : @"question",
        @"ios" : @"iosAnswer",
        @"web" : @"webAnswer",
        @"mobile" : @"mobileAnswer",
        @"@metadata.mapping.collectionIndex" : @"index"
    }];
    faqMapping.identificationAttributes = @[ @"question" ];
    responseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:faqMapping
                               method:RKRequestMethodGET
                          pathPattern:@"content"
                              keyPath:@"data.faq.questions"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];

    [errorMapping
        addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message"
                                                                 toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor
        responseDescriptorWithMapping:errorMapping
                               method:RKRequestMethodAny
                          pathPattern:nil
                              keyPath:nil
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [objectManager addResponseDescriptor:errorResponseDescriptor];

    RKObjectMapping *messageMapping = [RKObjectMapping mappingForClass:[HRPGResponseMessage class]];
    [messageMapping
     addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message"
                                                              toKeyPath:@"message"]];
    RKResponseDescriptor *messageResponseDescriptor = [RKResponseDescriptor
                                                       responseDescriptorWithMapping:messageMapping
                                                       method:RKRequestMethodAny
                                                       pathPattern:nil
                                                       keyPath:nil
                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:messageResponseDescriptor];
    
    RKObjectMapping *notificationMapping = [RKObjectMapping mappingForClass:[HRPGNotification class]];
    [notificationMapping addAttributeMappingsFromDictionary:@{
                                                              @"type": @"type",
                                                              @"id": @"id",
                                                              @"createdAt": @"createdAt",
                                                              @"data": @"data",
                                                              }];
    RKResponseDescriptor *notificationResponseDescriptor = [RKResponseDescriptor
                                                     responseDescriptorWithMapping:notificationMapping
                                                     method:RKRequestMethodAny
                                                     pathPattern:nil
                                                     keyPath:@"notifications"
                                                     statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:notificationResponseDescriptor];


    RKEntityMapping *shopMapping = [RKEntityMapping mappingForEntityForName:@"Shop"
                                                       inManagedObjectStore:managedObjectStore];
    [shopMapping addAttributeMappingsFromArray:@[@"text", @"identifier", @"notes", @"imageName", @"purchaseAll"]];
    shopMapping.identificationAttributes = @[ @"identifier" ];
    RKEntityMapping *shopCategoryMapping = [RKEntityMapping mappingForEntityForName:@"ShopCategory" inManagedObjectStore:managedObjectStore];
    [shopCategoryMapping addAttributeMappingsFromArray:@[@"text", @"identifier", @"notes", @"purchaseAll", @"pinType", @"path"]];
    [shopCategoryMapping addAttributeMappingsFromDictionary:@{@"@metadata.mapping.collectionIndex": @"index"}];
    shopCategoryMapping.identificationAttributes = @[ @"identifier" ];
    [shopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"categories"
                                                                    toKeyPath:@"categories"
                                                                  withMapping:shopCategoryMapping]];
    RKEntityMapping *shopItemMapping = [RKEntityMapping mappingForEntityForName:@"ShopItem" inManagedObjectStore:managedObjectStore];
    [shopItemMapping addAttributeMappingsFromArray:@[@"text", @"key", @"notes", @"type", @"value", @"currency", @"locked", @"purchaseType", @"path", @"pinType", @"owned", @"pinned"]];
    [shopItemMapping addAttributeMappingsFromDictionary:@{@"@metadata.mapping.collectionIndex": @"index",
                                                          @"class": @"imageName",
                                                          @"unlockCondition.condition": @"unlockCondition",
                                                          @"event.end": @"availableUntil",}];
    shopItemMapping.identificationAttributes = @[ @"key", @"purchaseType" ];
    [shopCategoryMapping
     addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                                    toKeyPath:@"items"
                                                                  withMapping:shopItemMapping]];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:shopMapping
                          method:RKRequestMethodGET
                          pathPattern:@"shops/market"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:shopMapping
                          method:RKRequestMethodGET
                          pathPattern:@"shops/seasonal"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:shopMapping
                          method:RKRequestMethodGET
                          pathPattern:@"shops/quests"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:shopMapping
                          method:RKRequestMethodGET
                          pathPattern:@"shops/time-travelers"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:shopCategoryMapping
                          method:RKRequestMethodGET
                          pathPattern:@"shops/market-gear"
                          keyPath:@"data.categories"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKEntityMapping *challengeMapping = [RKEntityMapping mappingForEntityForName:@"Challenge" inManagedObjectStore:managedObjectStore];
    [challengeMapping addAttributeMappingsFromArray:@[@"id", @"name", @"prize", @"shortName", @"createdAt", @"updatedAt", @"memberCount", @"official"]];
    [challengeMapping addAttributeMappingsFromDictionary:@{
                                                           @"description": @"notes",
                                                           @"leader.id": @"leaderId",
                                                           @"leader.profile.name": @"leaderName",
                                                           }];
    
    RKEntityMapping *challengeCategoryMapping = [RKEntityMapping mappingForEntityForName:@"ChallengeCategory" inManagedObjectStore:managedObjectStore];
    [challengeCategoryMapping addAttributeMappingsFromArray:@[@"name", @"slug"]];
    [challengeCategoryMapping addAttributeMappingsFromDictionary:@{@"_id": @"id"}];
    challengeCategoryMapping.identificationAttributes = @[@"id"];
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"categories"
                                                                                     toKeyPath:@"categories"
                                                                                   withMapping:challengeCategoryMapping]];
    
    RKEntityMapping *groupMapping = [RKEntityMapping mappingForEntityForName:@"Group" inManagedObjectStore:managedObjectStore];
    [groupMapping addAttributeMappingsFromArray:@[@"id", @"name"]];
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"group" toKeyPath:@"group" withMapping:groupMapping]];
    
    RKEntityMapping *challengeTaskOrderMapping = [RKEntityMapping mappingForEntityForName:@"ChallengeTask" inManagedObjectStore:managedObjectStore];
    [challengeTaskOrderMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"id"]];
    [challengeTaskOrderMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"@metadata.mapping.collectionIndex" toKeyPath:@"order"]];
    challengeTaskOrderMapping.identificationAttributes = @[ @"id" ];
    
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tasksOrder.habits" toKeyPath:@"habits" withMapping:challengeTaskOrderMapping]];
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tasksOrder.dailys" toKeyPath:@"dailies" withMapping:challengeTaskOrderMapping]];
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tasksOrder.todos" toKeyPath:@"todos" withMapping:challengeTaskOrderMapping]];
    [challengeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tasksOrder.rewards" toKeyPath:@"rewards" withMapping:challengeTaskOrderMapping]];
    
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:challengeMapping
                          method:RKRequestMethodGET
                          pathPattern:@"challenges/user"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:challengeMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"challenges/:id/join"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:challengeMapping
                          method:RKRequestMethodPOST
                          pathPattern:@"challenges/:id/leave"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    RKEntityMapping *challengeTaskMapping = [RKEntityMapping mappingForEntityForName:@"ChallengeTask" inManagedObjectStore:managedObjectStore];
    [challengeTaskMapping addAttributeMappingsFromArray:@[@"id", @"up", @"down", @"text", @"type", @"notes", @"value"]];
    challengeTaskMapping.identificationAttributes = @[@"id"];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:challengeTaskMapping
                          method:RKRequestMethodGET
                          pathPattern:@"tasks/challenge/:id/"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];

    RKObjectMapping *worldStateMapping = [RKObjectMapping mappingForClass:[HabiticaWorldState class]];
    [worldStateMapping addAttributeMappingsFromDictionary:@{
                                                     @"worldBoss.active" : @"worldBossActive",
                                                     @"worldBoss.key": @"worldBossKey",
                                                     @"worldBoss.progress.hp": @"worldBossHealth",
                                                     @"worldBoss.progress.rrage": @"worldBossRage"
                                                     }];
    responseDescriptor = [RKResponseDescriptor
                          responseDescriptorWithMapping:worldStateMapping
                          method:RKRequestMethodGET
                          pathPattern:@"world-state"
                          keyPath:@"data"
                          statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:responseDescriptor];
    

    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-client" value:@"habitica-ios"];

    [self setCredentials];
    if (currentUser != nil && currentUser.length > 0) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", currentUser];
        [fetchRequest setPredicate:predicate];
        NSArray *fetchedObjects =
            [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count] > 0) {
            self.user = [fetchedObjects firstObject];
            if ([fetchedObjects count] > 1) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Invalid number of user objects: %d", nil), [fetchedObjects count]],
                                           };
                NSError *error = [NSError errorWithDomain:NSSQLiteErrorDomain code:-10 userInfo:userInfo];
                [CrashlyticsKit recordError:error];
                for (int x = 1; x < fetchedObjects.count; x++) {
                    User *user = fetchedObjects[x];
                    [[self getManagedObjectContext] deleteObject:user];
                    [self fetchUser:nil onError:nil];
                }
            }
        } else {
            [self fetchUser:nil onError:nil];
        }
    }

    self.networkIndicatorController = [[HRPGNetworkIndicatorController alloc] init];
}

- (void)resetSavedDatabase:(BOOL)withUserData onComplete:(void (^)())completitionBlock {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startClearingData" object:nil];
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self getManagedObjectContext] performBlockAndWait:^{
            NSError *error = nil;
            for (NSEntityDescription *entity in [RKManagedObjectStore defaultStore]
                     .managedObjectModel) {
                NSFetchRequest *fetchRequest = [NSFetchRequest new];
                [fetchRequest setEntity:entity];
                [fetchRequest setIncludesSubentities:NO];
                NSArray *objects =
                    [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
                if (!objects)
                    RKLogWarning(@"Failed execution of fetch request %@: %@", fetchRequest, error);
                for (NSManagedObject *managedObject in objects) {
                    [[self getManagedObjectContext] deleteObject:managedObject];
                }
            }
            [[self getManagedObjectContext] processPendingChanges];
            BOOL success = [[self getManagedObjectContext] save:&error];
            if (!success) RKLogWarning(@"Failed saving managed object context: %@", error);
        }];
    }];
    operation.completionBlock = ^{
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSError *error;
        [[self getManagedObjectContext] saveToPersistentStore:&error];
        if (!error) {
            BOOL success = [[self getManagedObjectContext] save:&error];
            if (!success) RKLogWarning(@"Failed saving managed object context: %@", error);
            [self fetchContent:^() {
                NSError *error;
                [[self getManagedObjectContext] processPendingChanges];
                [[self getManagedObjectContext] saveToPersistentStore:&error];
                if (withUserData) {
                    [self fetchUser:^() {
                        completitionBlock();
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:@"finishedClearingData"
                                          object:nil];
                    }
                        onError:^() {
                            [[NSNotificationCenter defaultCenter]
                                postNotificationName:@"finishedClearingData"
                                              object:nil];
                            completitionBlock();
                        }];
                } else {
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:@"finishedClearingData"
                                      object:nil];
                    completitionBlock();
                }
            }
                onError:^() {
                    NSError *error;
                    [[self getManagedObjectContext] processPendingChanges];
                    [[self getManagedObjectContext] saveToPersistentStore:&error];
                    if (withUserData) {
                        [self fetchUser:^() {
                            [[NSNotificationCenter defaultCenter]
                                postNotificationName:@"finishedClearingData"
                                              object:nil];
                            completitionBlock();
                        }
                            onError:^() {
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"finishedClearingData"
                                                  object:nil];
                                completitionBlock();
                            }];
                    } else {
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:@"finishedClearingData"
                                          object:nil];
                        completitionBlock();
                    }
                }];
        }
    };
    [operation start];
}

- (NSManagedObjectContext *)getManagedObjectContext {
    return [managedObjectStore mainQueueManagedObjectContext];
}

- (void)setCredentials {
    AuthenticationManager *authManager = [AuthenticationManager shared];
    currentUser = authManager.currentUserId;
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-user" value:currentUser];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-key"
                                                           value:authManager.currentUserKey];
    
    HabiticaKeys *keys = [[HabiticaKeys alloc] init];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"Authorization"
                                                           value:[@"Basic " stringByAppendingString:[keys stagingKey]]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:@"&uid" value:self.user.id];
    [[Amplitude instance] setUserId:currentUser];
    [[Crashlytics sharedInstance] setUserIdentifier:currentUser];
    [[Crashlytics sharedInstance] setUserName:currentUser];
}

- (BOOL)hasAuthentication {
    return (currentUser != nil && currentUser.length > 0);
}

- (void)clearLoginCredentials {
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-user" value:@""];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"x-api-key" value:@""];
}

- (void)setTimezoneOffset {
    NSInteger offset = -[[NSTimeZone localTimeZone] secondsFromGMT] / 60;
    if (self.user.preferences) {
        if (!self.user.preferences.timezoneOffset ||
            offset != [self.user.preferences.timezoneOffset integerValue]) {
            self.user.preferences.timezoneOffset = @(offset);
            [self updateUser:@{
                @"preferences.timezoneOffset" : @(offset)
            }
                   onSuccess:nil
                     onError:nil];
        }
    }
}

- (void)fetchContent:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    NSString *url = @"content";
    if (self.user.preferences.language) {
        url = [url stringByAppendingFormat:@"?language=%@", self.user.preferences.language];
        [defaults setObject:self.user.preferences.language forKey:@"contentLanguage"];
        [defaults synchronize];
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:url
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            for (NSDictionary *dict in [mappingResult dictionary][@"backgrounds"]) {
                for (Customization *background in dict[@"backgrounds"]) {
                    background.type = @"background";
                    background.set = dict[@"setName"];
                    background.price = @7;
                    // TODO: Figure out why it is necessary to save each background individually
                    [background.managedObjectContext saveToPersistentStore:&executeError];
                }
            }

            NSString *textPath =
                [[NSBundle mainBundle] pathForResource:@"customizations" ofType:@"json"];
            NSError *error;
            NSString *content = [NSString stringWithContentsOfFile:textPath
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *customizations =
                [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error]
                    [@"customizations"];
            NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:1];

            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest
                setEntity:[NSEntityDescription entityForName:@"Customization"
                                      inManagedObjectContext:[self getManagedObjectContext]]];
            NSArray *existingCustomizations =
                [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];

            for (Customization *customization in existingCustomizations) {
                [identifiers addObject:[NSString stringWithFormat:@"%@%@", customization.type,
                                                                  customization.name]];
            }

            for (NSDictionary *data in customizations) {
                if ([identifiers containsObject:[NSString stringWithFormat:@"%@%@", data[@"type"],
                                                                           data[@"name"]]]) {
                    continue;
                }
                Customization *customization = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Customization"
                             inManagedObjectContext:[self getManagedObjectContext]];
                customization.name = data[@"name"];
                customization.text = data[@"text"];
                customization.notes = data[@"notes"];
                customization.type = data[@"type"];
                customization.group = data[@"group"];
                if (data[@"set"]) {
                    customization.set = data[@"set"];
                }
                customization.price = data[@"price"];
                customization.purchasable = data[@"purchasable"];
            }

            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            
            [defaults setObject:[NSDate date] forKey:@"lastContentFetch"];
            [defaults synchronize];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchTasks:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self fetchTasksForDay:nil onSuccess:successBlock onError:errorBlock];
}

- (void)fetchTasksForDay:(NSDate *)dueDate
               onSuccess:(void (^)())successBlock
                 onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSString *url = @"tasks/user";
    if (dueDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssXXX";
        __block NSString *dateString =  [formatter stringFromDate:dueDate];
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"T[0-9]:"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        [regex enumerateMatchesInString:dateString options:0 range:NSMakeRange(0, [dateString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            dateString = [NSString stringWithFormat:@"%@T0%@", [dateString substringToIndex:match.range.location], [dateString substringWithRange:NSMakeRange(match.range.location+1, dateString.length-match.range.location-1)]];
        }];
        url = [url stringByAppendingString:@"?type=dailys&dueDate="];
        url = [url stringByAppendingString:dateString];
        url = [url stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    }
    
    [[RKObjectManager sharedManager] getObjectsAtPath:url
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            [defaults setObject:[NSDate date] forKey:@"lastTaskFetch"];
            [defaults synchronize];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchCompletedTasks:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager]
     getObjectsAtPath:@"tasks/user?type=completedTodos"
     parameters:nil
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         NSError *executeError = nil;
         [[self getManagedObjectContext] saveToPersistentStore:&executeError];
         [defaults setObject:[NSDate date] forKey:@"lastTaskFetch"];
         [defaults synchronize];
         if (successBlock) {
             successBlock();
         }
         [self.networkIndicatorController endNetworking];
         return;
     }
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         if (errorBlock) {
             errorBlock();
         }
         [self.networkIndicatorController endNetworking];
         return;
     }];
}

- (void)fetchUser:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self fetchUser:YES onSuccess:successBlock onError:errorBlock];
}

- (void)fetchUser:(BOOL)includeTasks
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] getObjectsAtPath:@"user"
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            User *fetchedUser = [mappingResult dictionary][@"data"];
            if ([fetchedUser isKindOfClass:User.class]) {
                if (![currentUser isEqualToString:self.user.id]) {
                    NSFetchRequest *fetchRequest =
                        [NSFetchRequest fetchRequestWithEntityName:@"User"];
                    [fetchRequest setReturnsObjectsAsFaults:NO];
                    NSPredicate *predicate =
                        [NSPredicate predicateWithFormat:@"id==%@", fetchedUser.id];
                    [fetchRequest setPredicate:predicate];
                    NSError *error;
                    NSArray *fetchedObjects =
                        [[self getManagedObjectContext] executeFetchRequest:fetchRequest
                                                                      error:&error];
                    if ([fetchedObjects count] > 0) {
                        self.user = [fetchedObjects lastObject];
                        if ([fetchedObjects count] > 1) {
                            NSDictionary *userInfo = @{
                                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Invalid number of user objects: %d", nil), [fetchedObjects count]],
                                                       };
                            NSError *error = [NSError errorWithDomain:NSSQLiteErrorDomain code:-10 userInfo:userInfo];
                            [CrashlyticsKit recordError:error];
                        }
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:@"userChanged"
                                                                        object:nil];
                }
            }
            [self setTimezoneOffset];
            if (![[defaults stringForKey:@"contentLanguage"]
                    isEqualToString:self.user.preferences.language]) {
                [self fetchContent:nil onError:nil];
            }
            if ([defaults stringForKey:@"PushNotificationDeviceToken"]) {
                NSString *token = [defaults stringForKey:@"PushNotificationDeviceToken"];
                bool addDevice = YES;
                for (PushDevice *device in fetchedUser.pushDevices) {
                    if ([device.regId isEqualToString:token]) {
                        addDevice = NO;
                        break;
                    }
                }
                if (addDevice) {
                    [self addPushDevice:token onSuccess:nil onError:nil];
                }
            }
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            [defaults setObject:[NSDate date] forKey:@"lastTaskFetch"];
            [defaults synchronize];
            
            if (fetchedUser.subscriptionPlan.isActive) {
                [self updateMysteryItemCount];
            }
            if (includeTasks) {
                [self fetchTasks:^() {
                    [YesterdailiesDialogView showDialogWithSharedManager:self user:fetchedUser];
                    if (successBlock) {
                        successBlock();
                    }
                }onError:errorBlock];
            } else {
                [YesterdailiesDialogView showDialogWithSharedManager:self user:fetchedUser];
                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                if (successBlock) {
                    successBlock();
                }
            }
            self.user = fetchedUser;
            
            [self handleNotifications:[mappingResult dictionary][@"notifications"]];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)updateUser:(NSDictionary *)newValues
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    [self updateUser:newValues refetchUser:YES onSuccess:successBlock onError:errorBlock];
}

- (void)updateUser:(NSDictionary *)newValues refetchUser:(BOOL)refetchUser onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] putObject:nil
        path:@"user"
        parameters:newValues
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            // TODO: API currently does not return maxHealth, maxMP and toNextLevel. To set them to
            // correct values, fetch again until this is fixed.
            if (refetchUser) {
                [self fetchUser:NO onSuccess:^() {
                    NSError *executeError = nil;
                    [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                    if (successBlock) {
                        successBlock();
                    }
                } onError:nil];
            } else {
                if (successBlock) {
                    successBlock();
                }
            }
            [self handleNotifications:[mappingResult dictionary][@"notifications"]];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)changeClass:(NSString *)newClass
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSString *url;
    if (newClass) {
        url = [NSString stringWithFormat:@"user/change-class?class=%@", newClass];
    } else {
        url = @"user/change-class";
    }

    [[RKObjectManager sharedManager] postObject:nil
        path:url
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)disableClasses:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"user/disable-classes"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)fetchGroup:(NSString *)groupID
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager]
        getObjectsAtPath:[NSString stringWithFormat:@"groups/%@", groupID]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            Group *group = [mappingResult dictionary][@"data"];
            if ([group isKindOfClass:[NSArray class]]) {
                NSArray *array = (NSArray *)group;
                if (array.count > 0) {
                    group = array[0];
                }
            }
            if (group && [group.type isEqualToString:@"party"] && ![group.id isEqualToString:[self getUser].partyID]) {
                [self getUser].partyID = group.id;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"partyChanged"
                                                                    object:group];
            }
            
            NSError *error;
            for (ChatMessage *message in group.chatmessages) {
                message.attributedText = [HabiticaMarkdownHelper toHabiticaAttributedString:[message.text stringByReplacingEmojiCheatCodesWithUnicode] error:&error];
            }
            
            [self handleNotifications:[mappingResult dictionary][@"notifications"]];
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            if ([groupID isEqualToString:@"party"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"partyUpdated"
                                                                    object:nil];
            }
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (errorBlock) {
                errorBlock();
            }
            if (operation.HTTPRequestOperation.response.statusCode == 200) {
                [self fetchGroups:@"party"
                    onSuccess:nil onError:nil];
                return;
            }
            [self handleNetworkError:operation withError:error];

            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchGroups:(NSString *)groupType
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSDictionary *params = @{ @"type" : groupType };
    Group *oldTavern = [[[SocialRepository alloc] init] getGroup:@"00000000-0000-4000-A000-000000000000"];
    NSString *questKey = oldTavern.questKey;
    NSNumber *questActive = oldTavern.questActive;
    NSNumber *questHP = oldTavern.questHP;
    NSNumber *questRage = oldTavern.questRage;
    [[RKObjectManager sharedManager] getObjectsAtPath:@"groups"
        parameters:params
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            if ([groupType isEqualToString:@"party"]) {
                Group *group = [mappingResult dictionary][@"data"];
                if ([group isKindOfClass:[NSArray class]]) {
                    NSArray *array = (NSArray *)group;
                    if (array.count > 0) {
                        group = array[0];
                    }
                }
                [self getUser].partyID = group.id;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"partyChanged"
                                                                    object:group];
            } else if ([groupType isEqualToString:@"guilds"]) {
                NSArray *guilds = [mappingResult array];
                for (NSObject *obj in guilds) {
                    if ([obj isKindOfClass:[Group class]]) {
                        Group *guild = (Group *) obj;
                        guild.type = @"guild";
                        guild.isMember = @YES;
                    }
                }
            } else if ([groupType isEqualToString:@"publicGuilds"]) {
                NSArray *guilds = [mappingResult array];
                for (NSObject *obj in guilds) {
                    if ([obj isKindOfClass:[Group class]]) {
                        Group *guild = (Group *) obj;
                        if ([guild.id isEqualToString:@"00000000-0000-4000-A000-000000000000"]) {
                            guild.questKey = questKey;
                            guild.questActive = questActive;
                            guild.questHP = questHP;
                            guild.questRage = questRage;
                        }
                        guild.type = @"guild";
                    }
                }
            }
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchMember:(NSString *)memberId
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] getObjectsAtPath:[@"members/" stringByAppendingString:memberId]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchChallenges:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"challenges/user"
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSError *executeError = nil;
                                                  [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                  if (successBlock) {
                                                      successBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [self handleNetworkError:operation withError:error];
                                                  if (errorBlock) {
                                                      errorBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }];
}

- (void)fetchChallenge:(Challenge *)challenge
             onSuccess:(void (^)())successBlock
               onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"challenges/%@", challenge.id]
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSError *executeError = nil;
                                                  [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                  if (successBlock) {
                                                      successBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [self handleNetworkError:operation withError:error];
                                                  if (errorBlock) {
                                                      errorBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }];
}

- (void)joinChallenge:(Challenge *)challenge onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"challenges/%@/join", challenge.id]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSError *executeError = nil;
                                            [self fetchUser:nil onError:nil];
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)leaveChallenge:(Challenge *)challenge keepTasks:(Boolean)keepTasks onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    NSDictionary *body = nil;
    if (keepTasks) {
        body = @{@"keep": @"keep-all"};
    } else {
        body = @{@"keep": @"remove-all"};
    }
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"challenges/%@/leave", challenge.id]
                                     parameters:body
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSError *executeError = nil;
                                            challenge.user = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)fetchChallengeTasks:(Challenge *)challenge onSuccess:(void (^)())successBlock
                onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"tasks/challenge/%@/", challenge.id]
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSError *executeError = nil;
                                                  [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                  if (successBlock) {
                                                      successBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [self handleNetworkError:operation withError:error];
                                                  if (errorBlock) {
                                                      errorBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }];
}

- (void)upDownTask:(Task *)task
         direction:(NSString *)withDirection
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    if (task.id == nil || [task.id isEqualToString:@""]) {
        // Task is not saved on the server yet. Sending a request now would create a new empty
        // habit.
        return;
    }

    [self.networkIndicatorController beginNetworking];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"behaviour"
                                                          action:@"score task"
                                                           label:nil
                                                           value:nil] build]];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"tasks/%@/score/%@", task.id, withDirection]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGTaskResponse *taskResponse = (HRPGTaskResponse *)[mappingResult dictionary][@"data"];

            if ([task.managedObjectContext existingObjectWithID:task.objectID
                                                          error:&executeError] != nil) {
                task.value = @([task.value floatValue] + [taskResponse.delta floatValue]);
            }
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];

            if ([self.user.level integerValue] < [taskResponse.level integerValue]) {
                self.user.level = taskResponse.level;
                [self displayLevelUpNotification];
                // Set experience to the amount, that was missing for the next level. So that the
                // notification
                // displays the correct amount of experience gained
                self.user.experience =
                    @([self.user.experience floatValue] - [self.user.nextLevel floatValue]);
            }
            self.user.level = taskResponse.level ? taskResponse.level : self.user.level;

            NSNumber *expDiff =
                @([taskResponse.experience floatValue] - [self.user.experience floatValue]);
            self.user.experience = taskResponse.experience;
            NSNumber *healthDiff =
                @([taskResponse.health floatValue] - [self.user.health floatValue]);
            self.user.health = taskResponse.health ? taskResponse.health : self.user.health;
            NSNumber *magicDiff = @([taskResponse.magic floatValue] - [self.user.magic floatValue]);
            self.user.magic = taskResponse.magic ? taskResponse.magic : self.user.magic;

            NSNumber *goldDiff = @([taskResponse.gold floatValue] - [self.user.gold floatValue]);
            self.user.gold = taskResponse.gold ? taskResponse.gold : self.user.gold;
            
            self.user.pendingDamage = [NSNumber numberWithFloat:(self.user.pendingDamage.floatValue+taskResponse.questDamage.floatValue)];

            [self displayTaskSuccessNotification:healthDiff
                              withExperienceDiff:expDiff
                                    withGoldDiff:goldDiff
                                   withMagicDiff:magicDiff
                                 withQuestDamage:taskResponse.questDamage];
            if ([task.type isEqualToString:@"daily"] || [task.type isEqualToString:@"todo"]) {
                task.completed = @([withDirection isEqualToString:@"up"]);
            }

            if ([task.type isEqualToString:@"daily"]) {
                if ([withDirection isEqualToString:@"up"]) {
                    task.streak = @([task.streak integerValue] + 1);
                } else if ([task.streak integerValue] > 0) {
                    task.streak = @([task.streak integerValue] - 1);
                }
            }
            if ([task.type isEqualToString:@"habit"]) {
                if ([withDirection isEqualToString:@"up"]) {
                    task.counterUp = @([task.counterUp integerValue] + 1);
                } else {
                    task.counterDown = @([task.counterDown integerValue] + 1);
                }
            }

            if (self.user && self.user.health && [self.user.health floatValue] <= 0) {
                HRPGDeathView *deathView = [[HRPGDeathView alloc] init];
                [deathView show];
            }

            if (taskResponse.dropKey) {
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"behaviour"
                                                                      action:@"acquire item"
                                                                       label:nil
                                                                       value:nil] build]];

                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                // Edit the entity name as appropriate.
                NSEntityDescription *entity =
                    [NSEntityDescription entityForName:@"Item"
                                inManagedObjectContext:[self getManagedObjectContext]];
                [fetchRequest setEntity:entity];
                NSPredicate *predicate;
                predicate =
                    [NSPredicate predicateWithFormat:@"type==%@ || key==%@", taskResponse.dropType,
                                                     taskResponse.dropKey];
                [fetchRequest setPredicate:predicate];
                NSError *error = nil;
                NSArray *fetchedObjects =
                    [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
                if ([fetchedObjects count] == 1) {
                    Item *droppedItem = fetchedObjects[0];
                    droppedItem.owned = @([droppedItem.owned integerValue] + 1);
                    [self displayDropNotification:droppedItem.key
                                         withName:droppedItem.text
                                         withType:taskResponse.dropType
                                         withNote:taskResponse.dropNote];
                }
            }
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self handleNotifications:[mappingResult dictionary][@"notifications"]];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)scoreChecklistItem:(Task *)task checklistItem:(ChecklistItem *)item onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager]
     postObject:nil
     path:[NSString stringWithFormat:@"tasks/%@/checklist/%@/score", task.id, item.id]
     parameters:nil
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         if (successBlock) {
             successBlock();
         }
         [self handleNotifications:[mappingResult dictionary][@"notifications"]];
         [self.networkIndicatorController endNetworking];
         return;
     }
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [self handleNetworkError:operation withError:error];
         if (errorBlock) {
             errorBlock();
         }
         [self.networkIndicatorController endNetworking];
         return;
     }];}

- (void)getReward:(NSString *)rewardID
         withText:(NSString *)text
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"tasks/%@/score/down", rewardID]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGTaskResponse *taskResponse = (HRPGTaskResponse *)[mappingResult dictionary][@"data"];
            if ([self.user.level integerValue] < [taskResponse.level integerValue]) {
                [self displayLevelUpNotification];
                // Set experience to the amount, that was missing for the next level. So that the
                // notification
                // displays the correct amount of experience gained
                self.user.experience =
                    @([self.user.experience floatValue] - [self.user.nextLevel floatValue]);
            }
            self.user.level = taskResponse.level ? taskResponse.level : self.user.level;
            self.user.experience = taskResponse.experience ? taskResponse.experience : self.user.experience;
            self.user.health = taskResponse.health ? taskResponse.health : self.user.experience;
            self.user.magic = taskResponse.magic ? taskResponse.magic : self.user.magic;

            NSNumber *goldDiff = @([taskResponse.gold floatValue] - [self.user.gold floatValue]);
            self.user.gold = taskResponse.gold;
            [self displayRewardNotification:goldDiff];
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)createTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:task
        path:nil
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)createTasks:(NSArray *)tasks onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"tasks/user"
                                     parameters:tasks
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)updateTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] putObject:task
        path:nil
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)deleteTask:(Task *)task onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    if ([task.id isEqualToString:self.lastDeletedTaskID]) {
        return;
    }
    self.lastDeletedTaskID = task.id;
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] deleteObject:task
        path:[NSString stringWithFormat:@"tasks/%@", task.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)moveTask:(Task *)task toPosition:(NSNumber *)position onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    task.order = position;
    NSError *executeError = nil;
    [[self getManagedObjectContext] saveToPersistentStore:&executeError];
    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"tasks/%@/move/to/%@", task.id, position]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)createReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:reward
        path:nil
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            [self fetchTasks:^{
                if (successBlock) {
                    successBlock();
                }
            } onError:^{
                if (successBlock) {
                    successBlock();
                }
            }];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)updateReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] putObject:reward
        path:nil
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)deleteReward:(Reward *)reward
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] deleteObject:reward
        path:[NSString stringWithFormat:@"tasks/%@", reward.key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}


- (void)createTag:(Tag *)tag
           onSuccess:(void (^)(Tag *tag))successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] postObject:tag
                                           path:@"tags"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            Tag *tag = (Tag *)[mappingResult dictionary][@"data"];
                                            if (successBlock) {
                                                successBlock(tag);
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)updateTag:(Tag *)tag
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] putObject:tag
                                          path:nil
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           NSError *executeError = nil;
                                           [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                           if (successBlock) {
                                               successBlock();
                                           }
                                           [self.networkIndicatorController endNetworking];
                                           return;
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           [self handleNetworkError:operation withError:error];
                                           if (errorBlock) {
                                               errorBlock();
                                           }
                                           [self.networkIndicatorController endNetworking];
                                           return;
                                       }];
}

- (void)deleteTag:(Tag *)tag
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] deleteObject:tag
                                             path:nil
                                       parameters:nil
                                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                              NSError *executeError = nil;
                                              [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                              if (successBlock) {
                                                  successBlock();
                                              }
                                              [self.networkIndicatorController endNetworking];
                                              return;
                                          }
                                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              [self handleNetworkError:operation withError:error];
                                              if (errorBlock) {
                                                  errorBlock();
                                              }
                                              [self.networkIndicatorController endNetworking];
                                              return;
                                          }];
}

- (void)fetchBuyableRewards:(void (^)())successBlock onError:(void (^)())errorBlock {
    NSString *url = nil;
    if ([self.configRepository boolWithVariable:ConfigVariableEnableNewShops]) {
        url = @"user/in-app-rewards";
    } else {
        url = @"user/inventory/buy";
    }
    
    [[RKObjectManager sharedManager] getObjectsAtPath:url
                                           parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  NSError *executeError = nil;
                                                  
                                                  [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                  if (successBlock) {
                                                      successBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  [self handleNetworkError:operation withError:error];
                                                  if (errorBlock) {
                                                      errorBlock();
                                                  }
                                                  [self.networkIndicatorController endNetworking];
                                                  return;
                                              }];
}

- (void)clearCompletedTasks:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:@"tasks/clear-completed"
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)loginUser:(NSString *)username
     withPassword:(NSString *)password
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSDictionary *params = @{ @"username" : username, @"password" : password };
    [[RKObjectManager sharedManager] postObject:Nil
        path:@"user/auth/local/login"
        parameters:params
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            HRPGLoginData *loginData = (HRPGLoginData *)[mappingResult dictionary][@"data"];
            [[AuthenticationManager shared] setAuthenticationWithUserId:loginData.id key:loginData.key];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userChanged" object:nil];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)loginUserSocial:(NSString *)userID
            withNetwork:(NSString *)network
        withAccessToken:(NSString *)accessToken
              onSuccess:(void (^)())successBlock
                onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSDictionary *params = @{
        @"network" : network,
        @"authResponse" : @{@"access_token" : accessToken, @"client_id" : userID}
    };
    [[RKObjectManager sharedManager] postObject:Nil
        path:@"user/auth/social"
        parameters:params
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            HRPGLoginData *loginData = (HRPGLoginData *)[mappingResult dictionary][@"data"];
            [[AuthenticationManager shared] setAuthenticationWithUserId:loginData.id key:loginData.key];

            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)registerUser:(NSString *)username
        withPassword:(NSString *)password
           withEmail:(NSString *)email
           onSuccess:(void (^)())successBlock
             onError:(void (^)(NSString *errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSDictionary *params = @{
        @"username" : username,
        @"password" : password,
        @"confirmPassword" : password,
        @"email" : email
    };
    [[RKObjectManager sharedManager] postObject:Nil
        path:@"user/auth/local/register"
        parameters:params
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self loginUser:username
                withPassword:password
                onSuccess:^() {
                    if (successBlock) {
                        successBlock();
                    }
                }
                onError:nil];

            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (operation.HTTPRequestOperation.response.statusCode == 503) {
                [self displayServerError];
            } else if (operation.HTTPRequestOperation.response.statusCode == 401) {
                RKErrorMessage *errorMessage = [error userInfo][RKObjectMapperErrorObjectsKey][0];
                if (errorBlock) {
                    errorBlock(errorMessage.errorMessage);
                }
            } else {
                [self displayNetworkError];
            }

            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)sleepInn:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:@"user/sleep"
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            self.user.preferences.sleep = @(![self.user.preferences.sleep boolValue]);
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)reviveUser:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:@"user/revive"
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self fetchUser:^{
                if (successBlock) {
                    successBlock();
                }
            } onError:^{
                if (successBlock) {
                    successBlock();
                }
            }];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (operation.HTTPRequestOperation.response.statusCode == 503) {
                [self displayServerError];
            } else if (operation.HTTPRequestOperation.response.statusCode == 401) {
                [self fetchUser:^{
                    if (successBlock) {
                        successBlock();
                    }
                } onError:^{
                    if (errorBlock) {
                        errorBlock();
                    }
                }];
            } else {
                [self displayNetworkError];
            }
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)buyObject:(NSString *)key
        withValue:(NSNumber *)value
         withText:(NSString *)text
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:[NSString stringWithFormat:@"user/buy/%@", key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGUserBuyResponse *response = [mappingResult dictionary][@"data"];
            self.user.health = response.health ? response.health : self.user.health;
            NSNumber *goldDiff;
            if (response.gold) {
                goldDiff = @([response.gold floatValue] - [self.user.gold floatValue]);
                self.user.gold = response.gold;
            } else {
                goldDiff = value;
                self.user.gold = [NSNumber numberWithFloat:[self.user.gold floatValue] - [goldDiff floatValue]];
            }
            if (response.experience) {
                self.user.experience = response.experience;
            } else {
                if ([response.armoireType isEqualToString:@"experience"]) {
                    self.user.experience = [NSNumber numberWithFloat:[self.user.experience floatValue] + [response.armoireValue floatValue]];
                } else {
                    [self fetchUser:nil onError:nil];
                }
            }
            self.user.magic = response.magic ? response.magic : self.user.magic;
            self.user.equipped.armor = response.equippedArmor ? response.equippedArmor : self.user.equipped.armor;
            self.user.equipped.back = response.equippedBack ? response.equippedBack : self.user.equipped.back;
            self.user.equipped.head = response.equippedHead ? response.equippedHead : self.user.equipped.head;
            self.user.equipped.headAccessory = response.equippedHeadAccessory ? response.equippedHeadAccessory : self.user.equipped.headAccessory;
            self.user.equipped.shield = response.equippedShield ? response.equippedShield : self.user.equipped.shield;
            self.user.equipped.weapon = response.equippedWeapon ? response.equippedWeapon : self.user.equipped.weapon;

            if (response.armoireType) {
                HRPGResponseMessage *message = [mappingResult dictionary][[NSNull null]];
                [self displayArmoireNotification:response.armoireType
                                         withKey:response.armoireKey
                                        withText:message.message
                                       withValue:response.armoireValue];
                
                [self fetchBuyableRewards:^{
                    if (successBlock) {
                        successBlock();
                    }
                } onError:^{
                    if (successBlock) {
                        successBlock();
                    }
                }];
            } else {
                [self displayItemBoughtNotification:goldDiff withText:text];
                if (successBlock) {
                    successBlock();
                }
            }
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)unlockPath:(NSString *)path
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"user/unlock?path=%@", path]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self fetchUser:^() {
                if (successBlock) {
                    successBlock();
                }
            }
                onError:nil];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)sellItem:(Item *)item onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:[NSString stringWithFormat:@"user/sell/%@/%@", item.type, item.key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGUserBuyResponse *response = [mappingResult dictionary][@"data"];
            self.user.health = response.health ? response.health : self.user.health;
            self.user.gold = response.gold ? response.health : self.user.gold;
            self.user.magic = response.magic ? response.health : self.user.magic;
            self.user.equipped.armor = response.equippedArmor ? response.equippedArmor : self.user.equipped.armor;
            self.user.equipped.back = response.equippedBack ? response.equippedBack : self.user.equipped.back;
            self.user.equipped.head = response.equippedHead ? response.equippedHead : self.user.equipped.head;
            self.user.equipped.headAccessory = response.equippedHeadAccessory ? response.equippedHeadAccessory : self.user.equipped.headAccessory;
            self.user.equipped.shield = response.equippedShield ? response.equippedShield : self.user.equipped.shield;
            self.user.equipped.weapon = response.equippedWeapon ? response.equippedWeapon : self.user.equipped.weapon;
            item.owned = @([item.owned intValue] - 1);
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)openMysteryItem:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] postObject:Nil
                                           path:@"user/open-mystery-item"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^{
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                            } onError:^{
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                            }];
                                            [self displayMysteryItemNotification:[mappingResult dictionary][@"data"]];
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)equipObject:(NSString *)key
           withType:(NSString *)type
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:[NSString stringWithFormat:@"user/equip/%@/%@", type, key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGUserBuyResponse *response = [mappingResult dictionary][@"data"];
            self.user.equipped.headAccessory = response.equippedHeadAccessory;
            self.user.equipped.armor = response.equippedArmor;
            self.user.equipped.back = response.equippedBack;
            self.user.equipped.body = response.equippedBody;
            self.user.equipped.eyewear = response.equippedEyewear;
            self.user.equipped.head = response.equippedHead;
            self.user.equipped.shield = response.equippedShield;
            self.user.equipped.weapon = response.equippedWeapon;
            self.user.costume.armor = response.costumeArmor;
            self.user.costume.back = response.costumeBack;
            self.user.costume.body = response.costumeBody;
            self.user.costume.eyewear = response.costumeEyewear;
            self.user.costume.head = response.costumeHead;
            self.user.costume.headAccessory = response.costumeHeadAccessory;
            self.user.costume.shield = response.costumeShield;
            self.user.costume.weapon = response.costumeWeapon;
            self.user.currentMount = response.currentMount;
            self.user.currentPet = response.currentPet;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)hatchEgg:(NSString *)egg withPotion:(NSString *)hPotion onSuccess:(void (^)(NSString *))successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:Nil
        path:[NSString stringWithFormat:@"user/hatch/%@/%@", egg, hPotion]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            HRPGUserBuyResponse *response = [mappingResult dictionary][@"data"];
            self.user.equipped.headAccessory = response.equippedHeadAccessory;
            self.user.equipped.armor = response.equippedArmor;
            self.user.equipped.back = response.equippedBack;
            self.user.equipped.body = response.equippedBody;
            self.user.equipped.eyewear = response.equippedEyewear;
            self.user.equipped.head = response.equippedHead;
            self.user.equipped.shield = response.equippedShield;
            self.user.equipped.weapon = response.equippedWeapon;
            self.user.costume.armor = response.costumeArmor;
            self.user.costume.back = response.costumeBack;
            self.user.costume.body = response.costumeBody;
            self.user.costume.eyewear = response.costumeEyewear;
            self.user.costume.head = response.costumeHead;
            self.user.costume.headAccessory = response.costumeHeadAccessory;
            self.user.costume.shield = response.costumeShield;
            self.user.costume.weapon = response.costumeWeapon;
            self.user.currentMount = response.currentMount;
            self.user.currentPet = response.currentPet;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            HRPGResponseMessage *message = [mappingResult dictionary][[NSNull null]];
            if (successBlock) {
                successBlock(message.message);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)castSpell:(Spell *)spell
    withTargetType:(NSString *)targetType
          onTarget:(NSString *)target
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSString *url = nil;
    NSInteger mana = [self.user.magic integerValue];
    if (target) {
        url = [NSString stringWithFormat:@"user/class/cast/%@?targetType=%@&targetId=%@", spell.key,
                                         targetType, target];
    } else {
        url = [NSString stringWithFormat:@"user/class/cast/%@?targetType=%@", spell.key, targetType];
    }
    [[RKObjectManager sharedManager] postObject:nil
        path:url
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self fetchUser:^() {
                NSError *executeError = nil;
                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                if ([spell.klass isEqualToString:@"special"]) {
                    [self displayTransformationItemNotification:spell.text withImage:spell.key];
                } else {
                    [self displaySpellNotification:(mana - [self.user.magic integerValue]) withSpellname:spell.text];
                }
                if (successBlock) {
                    successBlock();
                }
                [self.networkIndicatorController endNetworking];
                return;
            }
                    onError:nil];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)changeDayStartTime:(NSNumber *)dayStart onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [[RKObjectManager sharedManager]
     postObject:nil
     path:@"user/custom-day-start"
     parameters:@{@"dayStart": dayStart}
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self getUser].preferences.dayStart = dayStart;
         NSError *executeError = nil;
         [[self getManagedObjectContext] saveToPersistentStore:&executeError];
         if (successBlock) {
             successBlock();
         }
         [self.networkIndicatorController endNetworking];
         return;
     }
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [self handleNetworkError:operation withError:error];
         if (errorBlock) {
             errorBlock();
         }
         [self.networkIndicatorController endNetworking];
         return;
     }];
}

- (void)acceptQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)(NSString * errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/accept", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                NSString *errorMessage = @"";
                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                }
                errorBlock(errorMessage);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)chatSeen:(NSString *)group {
    if (group == nil || group.length == 0) {
        return;
    }
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/chat/seen", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            [self.networkIndicatorController endNetworking];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"partyUpdated" object:nil];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)markInboxSeen:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"user/mark-pms-read"
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self getUser].inboxNewMessages = @0;
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            [self.networkIndicatorController endNetworking];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            [self.networkIndicatorController endNetworking];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            return;
                                        }];
}

- (void)rejectQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)(NSString *errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/reject", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                NSString *errorMessage = @"";
                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                }
                errorBlock(errorMessage);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)abortQuest:(NSString *)group
         onSuccess:(void (^)())successBlock
           onError:(void (^)(NSString *errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/abort", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                NSString *errorMessage = @"";
                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                }
                errorBlock(errorMessage);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)cancelQuest:(NSString *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)(NSString *errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/cancel", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                NSString *errorMessage = @"";
                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                }
                errorBlock(errorMessage);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)forceStartQuest:(NSString *)group
              onSuccess:(void (^)())successBlock
                onError:(void (^)(NSString *errorMessage))errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/force-start", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                NSString *errorMessage = @"";
                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                }
                errorBlock(errorMessage);
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)inviteToQuest:(NSString *)group
            withQuest:(Quest *)quest
            onSuccess:(void (^)())successBlock
              onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/quests/invite/%@", group, quest.key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (quest) {
                quest.owned = @([quest.owned intValue] - 1);
            }
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)createGroup:(Group *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:group
        path:nil
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;

            if ([group.type isEqualToString:@"party"]) {
                Group *party = [mappingResult dictionary][@"data"];
                [self getUser].partyID = party.id;
            }

            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)updateGroup:(Group *)group
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] putObject:group
        path:[NSString stringWithFormat:@"groups/%@", group.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)inviteMembers:(NSArray *)members
    withInvitationType:(NSString *)invitationType
         toGroupWithID:(NSString *)group
             onSuccess:(void (^)())successBlock
               onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    if (members == nil || invitationType == nil) {
        if (errorBlock != nil) {
            errorBlock();
        }
        return;
    }
    
    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/invite", group]
        parameters:@{
            invitationType : members,
            @"inviter" : self.user.username != nil ? self.user.username : @""
        }
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)joinGroup:(NSString *)group
         withType:(NSString *)type
        onSuccess:(void (^)())successBlock
          onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/join", group]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            Group *group = [mappingResult dictionary][@"data"];
            if ([type isEqualToString:@"party"]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if (![group.id isEqualToString:[defaults stringForKey:@"partyID"]]) {
                    [defaults setObject:group.id forKey:@"partyID"];
                    [defaults synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"partyChanged"
                                                                        object:group];
                }
            }
            group.isMember = @YES;

            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)leaveGroup:(Group *)group
          withType:(NSString *)type
         onSuccess:(void (^)())successBlock
           onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/leave", group.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            if ([type isEqualToString:@"party"]) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:nil forKey:@"partyID"];
                [defaults synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"partyChanged"
                                                                    object:group];
            }
            group.isMember = @NO;

            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)fetchGroupMembers:(NSString *)groupID
         withPublicFields:(BOOL)withPublicFields
                 fetchAll:(BOOL)fetchAll
                onSuccess:(void (^)())successBlock
                  onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (withPublicFields) {
        parameters[@"includeAllPublicFields"] = @"true";
    }

    [[RKObjectManager sharedManager] getObject:nil
        path:[NSString stringWithFormat:@"groups/%@/members", groupID]
        parameters:parameters
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)chatMessage:(NSString *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/chat", groupID]
        parameters:@{
            @"message" : message
        }
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newChatMessage"
                                                                object:groupID];
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (operation.HTTPRequestOperation.response.statusCode == 401 || operation.HTTPRequestOperation.response.statusCode == 400) {
                HabiticaAlertController *alertController = [HabiticaAlertController alertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription];
                [alertController addCloseActionWithHandler:nil];
                [alertController show];
            } else {
                [self handleNetworkError:operation withError:error];
            }
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)privateMessage:(InboxMessage *)message toUserWithID:(NSString *)userID onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"members/send-private-message"
                                     parameters:@{
                                                  @"message" : message.text,
                                                  @"toUserId" : userID
                                                  }
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^{
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                            } onError:errorBlock];
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)deleteMessage:(ChatMessage *)message
            withGroup:(NSString *)groupID
            onSuccess:(void (^)())successBlock
              onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] deleteObject:message
        path:[NSString stringWithFormat:@"groups/%@/chat/%@", groupID, message.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)deletePrivateMessage:(InboxMessage *)message
            onSuccess:(void (^)())successBlock
              onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] deleteObject:message
                                             path:[NSString stringWithFormat:@"user/messages/%@", message.id]
                                       parameters:nil
                                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                              NSError *executeError = nil;
                                              [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                              if (successBlock) {
                                                  successBlock();
                                              }
                                              [self.networkIndicatorController endNetworking];
                                              return;
                                          }
                                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              [self handleNetworkError:operation withError:error];
                                              if (errorBlock) {
                                                  errorBlock();
                                              }
                                              [self.networkIndicatorController endNetworking];
                                              return;
                                          }];
}

- (void)likeMessage:(ChatMessage *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/chat/%@/like", groupID, message.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)flagMessage:(ChatMessage *)message
          withGroup:(NSString *)groupID
          onSuccess:(void (^)())successBlock
            onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"groups/%@/chat/%@/flag", groupID, message.id]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSError *executeError = nil;
            //[self.managedObjectContext deleteObject:message];
            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)feedPet:(Pet *)pet
       withFood:(Food *)food
      onSuccess:(void (^)())successBlock
        onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"user/feed/%@/%@", pet.key, food.key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            NSDictionary *result = [mappingResult dictionary][@"data"];
            NSNumber *petStatus = result[@"value"];

            NSError *executeError = nil;
            pet.trained = petStatus;
            food.owned = @([food.owned integerValue] - 1);
            [[self managedObjectContext] saveToPersistentStore:&executeError];

            NSString *preferenceString;
            if ([pet likesFood:food]) {
                preferenceString = NSLocalizedString(@"Your pet really likes the %@!", nil);
            } else {
                preferenceString =
                    NSLocalizedString(@"Your pet eats the %@ but doesn't seem to enjoy it.", nil);
            }
            [ToastManager showWithText:[NSString stringWithFormat:preferenceString, food.text] color:ToastColorGray];
            if ([result[@"value"] integerValue] == -1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayMountRaisedNotification:pet];
                });
                [self fetchUser:nil onError:nil];
            }

            if (successBlock) {
                successBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;

        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)purchaseGems:(NSDictionary *)receipt
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"behaviour"
                                                          action:@"purchase gems"
                                                           label:nil
                                                           value:nil] build]];

    [[RKObjectManager sharedManager] postObject:nil
        path:@"iap/ios/verify"
        parameters:receipt
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self fetchUser:^() {
                NSError *executeError = nil;
                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                 if (successBlock) {
                     successBlock();
                 }
                [self.networkIndicatorController endNetworking];
                return;
            }
                    onError:nil];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [CrashlyticsKit recordError:error];
            RKErrorMessage *errorMessage = [error userInfo][RKObjectMapperErrorObjectsKey][0];
            if ([errorMessage.errorMessage isEqualToString:@"INVALID_ITEM_PURCHASED"]) {
                if (successBlock) {
                    successBlock();
                }
                return;
            }
            if (operation.HTTPRequestOperation.response.statusCode == 503) {
                [self displayServerError];
            } else if (operation.HTTPRequestOperation.response.statusCode != 401) {
                [self displayNetworkError];
            }
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

-(void)subscribe:(NSString *)sku withReceipt:(NSString *)receipt onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"behaviour"
                                                          action:@"subscribe"
                                                           label:nil
                                                           value:nil] build]];
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"iap/ios/subscribe"
                                     parameters:@{@"sku": sku, @"receipt": receipt}
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^() {
                                                NSError *executeError = nil;
                                                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                                [self.networkIndicatorController endNetworking];
                                                return;
                                            }
                                                    onError:nil];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            if (operation.HTTPRequestOperation.response.statusCode == 503) {
                                                [self displayServerError];
                                            } else if (operation.HTTPRequestOperation.response.statusCode != 401) {
                                                [self displayNetworkError];
                                            }
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)purchaseItem:(NSString *)key
    withPurchaseType:(NSString *)purchaseType
            withText:(NSString *)text
       withImageName:(NSString *)imageName
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
        path:[NSString stringWithFormat:@"user/purchase/%@/%@", purchaseType, key]
        parameters:nil
        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self fetchUser:^() {
                NSError *executeError = nil;
                
                NSError *error;
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"ShopItem" inManagedObjectContext:[self getManagedObjectContext]]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
                
                NSArray *existingItems =
                [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
                if (existingItems.count > 0) {
                    ShopItem *item = existingItems.firstObject;
                    if ([@"gem" isEqualToString:key]) {
                        item.itemsLeft = @([item.itemsLeft integerValue] - 1);
                    }
                    item.lastPurchased = [NSDate date];
                }
                
                
                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                [self displayPurchaseNotification:[NSString stringWithFormat:NSLocalizedString(@"You purchased %@", nil), text] withImage:imageName];
                if (successBlock) {
                    successBlock();
                }
                [self.networkIndicatorController endNetworking];
                return;
            }
                    onError:nil];
            return;
        }
        failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
}

- (void)purchaseHourglassItem:(NSString *)key
             withPurchaseType:(NSString *)purchaseType
                     withText:(NSString *)text
                withImageName:(NSString *)imageName
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"user/purchase-hourglass/%@/%@", purchaseType, key]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^() {
                                                NSError *executeError = nil;
                                                
                                                NSError *error;
                                                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                                                [fetchRequest setEntity:[NSEntityDescription entityForName:@"ShopItem" inManagedObjectContext:[self getManagedObjectContext]]];
                                                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
                                                
                                                NSArray *existingItems =
                                                [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
                                                if (existingItems.count > 0) {
                                                    ShopItem *item = existingItems.firstObject;
                                                    item.lastPurchased = [NSDate date];
                                                }
                                                
                                                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                [self displayPurchaseNotification:[NSString stringWithFormat:NSLocalizedString(@"You purchased %@", nil), text] withImage:imageName];
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                                [self.networkIndicatorController endNetworking];
                                                return;
                                            }
                                                    onError:nil];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)purchaseMysterySet:(NSString *)key
                    onSuccess:(void (^)())successBlock
                      onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"user/buy-mystery-set/%@", key]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^() {
                                                NSError *executeError = nil;
                                                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                [self displayPurchaseNotification:NSLocalizedString(@"You purchased the set.", nil) withImage:nil];
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                                [self.networkIndicatorController endNetworking];
                                                return;
                                            }
                                                    onError:nil];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)purchaseQuest:(NSString *)key
             withText:(NSString *)text
        withImageName:(NSString *)imageName
                    onSuccess:(void (^)())successBlock
                      onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"user/buy-quest/%@", key]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchUser:^() {
                                                NSError *executeError = nil;
                                                
                                                NSError *error;
                                                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                                                [fetchRequest setEntity:[NSEntityDescription entityForName:@"ShopItem" inManagedObjectContext:[self getManagedObjectContext]]];
                                                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", key]];
                                                
                                                NSArray *existingItems =
                                                [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
                                                if (existingItems.count > 0) {
                                                    ShopItem *item = existingItems.firstObject;
                                                    item.lastPurchased = [NSDate date];
                                                }
                                                
                                                [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                                [self displayPurchaseNotification:[NSString stringWithFormat:NSLocalizedString(@"You purchased %@", nil), text] withImage:imageName];
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                                [self.networkIndicatorController endNetworking];
                                                return;
                                            }
                                                    onError:nil];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)addPushDevice:(NSString *)token
           onSuccess:(void (^)())successBlock
             onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"user/push-devices"
                                     parameters:@{
                                                  @"regId": token,
                                                  @"type": @"ios"
                                                  }
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)removePushDevice:(void (^)())successBlock
              onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    if ([defaults stringForKey:@"PushNotificationDeviceToken"]) {
        NSString *token = [defaults stringForKey:@"PushNotificationDeviceToken"];
        [defaults removeObjectForKey:@"PushNotificationDeviceToken"];

        [[RKObjectManager sharedManager] deleteObject:nil
                                           path:[@"user/push-devices/" stringByAppendingString:token]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
    }
}

- (void)fetchShopInventory:(NSString *)shopInventory onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];

    NSString *url = @"shops/";
    if ([shopInventory isEqualToString:MarketKey]) {
        url = [url stringByAppendingString:@"market"];
    } else if ([shopInventory isEqualToString:GearMarketKey]) {
        url = [url stringByAppendingString:@"market-gear"];
    } else if ([shopInventory isEqualToString:QuestsShopKey]) {
        url = [url stringByAppendingString:@"quests"];
    } else if ([shopInventory isEqualToString:SeasonalShopKey]) {
        url = [url stringByAppendingString:@"seasonal"];
    } else if ([shopInventory isEqualToString:TimeTravelersShopKey]) {
        url = [url stringByAppendingString:@"time-travelers"];
    } else {
        return;
    }
    [[RKObjectManager sharedManager] getObject:nil
                                           path:url
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self.networkIndicatorController endNetworking];
                                            
                                            if ([shopInventory isEqualToString:MarketKey]) {
                                                [self insertSubscriberShopItems];
                                            }
                                            
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)markNotificationRead:(HRPGNotification *)notification onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] postObject:nil
                                             path:[NSString stringWithFormat:@"notifications/%@/read", notification.id]
                                       parameters:nil
                                          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                              [self.networkIndicatorController endNetworking];
                                              if (successBlock) {
                                                  successBlock();
                                              }
                                              return;
                                          }
                                          failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              [self handleNetworkError:operation withError:error];
                                              if (errorBlock) {
                                                  errorBlock();
                                              }
                                              [self.networkIndicatorController endNetworking];
                                              return;
                                          }];
}

- (void)runCron:(NSArray<Task *> *)completedTasks onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self getUser].lastCron = [NSDate date];
    if (completedTasks.count > 0) {
        Task *task = [completedTasks lastObject];
        [self upDownTask:task direction:@"up" onSuccess:^{
            [self runCron:[completedTasks subarrayWithRange:NSMakeRange(0, completedTasks.count-1)] onSuccess:successBlock onError:errorBlock];
        } onError:errorBlock];
    } else {
        [self.networkIndicatorController beginNetworking];
        [[RKObjectManager sharedManager] postObject:nil path:@"cron" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [self.networkIndicatorController endNetworking];
            [self fetchUser:successBlock onError:errorBlock];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [self handleNetworkError:operation withError:error];
            if (errorBlock) {
                errorBlock();
            }
            [self.networkIndicatorController endNetworking];
            return;
        }];
    }
}

- (void)resetAccount:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] postObject:nil path:@"user/reset" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        [self fetchUser:successBlock onError:errorBlock];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)deleteAccount:(NSString *)password successBlock:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] deleteObject:nil path:@"user" parameters:@{@"password": password} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        [self fetchUser:successBlock onError:errorBlock];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)logoutUser:(void (^)())completionBlock {
    void (^logoutBlock)() = ^() {
        [[AuthenticationManager shared] clearAuthenticationForAllUsers];
        [defaults setObject:@"" forKey:@"partyID"];
        [defaults setObject:@"" forKey:@"habitFilter"];
        [defaults setObject:@"" forKey:@"dailyFilter"];
        [defaults setObject:@"" forKey:@"todoFilter"];
        [[HRPGManager sharedManager] clearLoginCredentials];
        
        [[HRPGManager sharedManager]
         resetSavedDatabase:NO
         onComplete:^() {
             if (completionBlock != nil) {
                 completionBlock();
             }
         }];
    };
    
    if ([defaults stringForKey:@"PushNotificationDeviceToken"]) {
        [[HRPGManager sharedManager] removePushDevice:^{
            logoutBlock();
        } onError:^{
            logoutBlock();
        }];
    } else {
        logoutBlock();
    }
}

- (void)changeEmail:(NSString *)newEmail withPassword:(NSString *)password successBlock:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] putObject:nil path:@"user/auth/update-email" parameters:@{@"newEmail": newEmail, @"password": password} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        self.user.email = newEmail;
        if (successBlock) {
            successBlock();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)changeLoginName:(NSString *)newLoginName withPassword:(NSString *)password successBlock:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] putObject:nil path:@"user/auth/update-username" parameters:@{@"username": newLoginName, @"password": password} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        self.user.loginname = newLoginName;
        if (successBlock) {
            successBlock();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword confirmPassword:(NSString *)confirmedPassword successBlock:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] putObject:nil path:@"user/auth/update-password" parameters:@{@"newPassword": newPassword, @"password": oldPassword, @"confirmPassword": confirmedPassword} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        if (successBlock) {
            successBlock();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)sendPasswordResetEmail:(NSString *)email
                     onSuccess:(void (^)())successBlock
                       onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] postObject:nil path:@"user/reset-password" parameters:@{@"email": email} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self.networkIndicatorController endNetworking];
        if (successBlock) {
            successBlock();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)togglePinnedItem:(NSString *)pinType withPath:(NSString *)path onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] getObject:nil
                                           path:[NSString stringWithFormat:@"user/toggle-pinned-item/%@/%@", pinType, path]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            [self fetchBuyableRewards:^() {
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                            }
                                                    onError:nil];
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                errorBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)reroll:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] getObject:nil
                                          path:@"user/reroll"
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           [self fetchUser:^{
                                               if (successBlock) {
                                                   successBlock();
                                               }
                                           } onError:^{
                                               if (successBlock) {
                                                   successBlock();
                                               }
                                           }];
                                           [self.networkIndicatorController endNetworking];
                                           return;
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           [self handleNetworkError:operation withError:error];
                                           if (errorBlock) {
                                               errorBlock();
                                           }
                                           [self.networkIndicatorController endNetworking];
                                           return;
                                       }];
}

- (void)allocateAttributePoint:(NSString *)attribute onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:[NSString stringWithFormat:@"user/allocate?stat=%@", attribute]
                                     parameters:nil
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            Stats *stats = [mappingResult dictionary][@"data"];
                                            self.user.strength = [NSNumber numberWithLong:stats.strength];
                                            self.user.intelligence = [NSNumber numberWithLong:stats.intelligence];
                                            self.user.constitution = [NSNumber numberWithLong:stats.constitution];
                                            self.user.perception = [NSNumber numberWithLong:stats.perception];
                                            self.user.pointsToAllocate = [NSNumber numberWithLong:stats.points];
                                            self.user.magic = [NSNumber numberWithFloat:stats.mana];
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                NSString *errorMessage = @"";
                                                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                                                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                                                }
                                                errorBlock(errorMessage);
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
     }

- (void)bulkAllocateAttributePoint:(NSInteger)strengthValue intelligence:(NSInteger)intelligenceValue constitution:(NSInteger)constitutionValue perception:(NSInteger)perceptionValue onSuccess:(void (^)())successBlock onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    
    [[RKObjectManager sharedManager] postObject:nil
                                           path:@"user/allocate-bulk"
                                     parameters:@{@"stats": @{@"str": [NSNumber numberWithLong:strengthValue], @"int": [NSNumber numberWithLong:intelligenceValue], @"con": [NSNumber numberWithLong:constitutionValue], @"per": [NSNumber numberWithLong:perceptionValue]}}
                                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                            Stats *stats = [mappingResult dictionary][@"data"];
                                            self.user.strength = [NSNumber numberWithLong:stats.strength];
                                            self.user.intelligence = [NSNumber numberWithLong:stats.intelligence];
                                            self.user.constitution = [NSNumber numberWithLong:stats.constitution];
                                            self.user.perception = [NSNumber numberWithLong:stats.perception];
                                            self.user.pointsToAllocate = [NSNumber numberWithLong:stats.points];
                                            self.user.magic = [NSNumber numberWithFloat:stats.mana];
                                            NSError *executeError = nil;
                                            [[self getManagedObjectContext] saveToPersistentStore:&executeError];
                                            if (successBlock) {
                                                successBlock();
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }
                                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                            [self handleNetworkError:operation withError:error];
                                            if (errorBlock) {
                                                NSString *errorMessage = @"";
                                                if (((NSArray *)[error userInfo][RKObjectMapperErrorObjectsKey]).count > 0) {
                                                    errorMessage = ((RKErrorMessage *)[error userInfo][RKObjectMapperErrorObjectsKey][0]).errorMessage;
                                                }
                                                errorBlock(errorMessage);
                                            }
                                            [self.networkIndicatorController endNetworking];
                                            return;
                                        }];
}

- (void)fetchWorldState:(void (^)())successBlock
                       onError:(void (^)())errorBlock {
    [self.networkIndicatorController beginNetworking];
    [[RKObjectManager sharedManager] getObject:nil path:@"world-state" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HabiticaWorldState *state = [mappingResult dictionary][@"data"];
        Group *tavern = [[[SocialRepository alloc] init] getGroup:@"00000000-0000-4000-A000-000000000000"];
        if (tavern == nil) {
            tavern = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:[self getManagedObjectContext]];
            tavern.id = @"00000000-0000-4000-A000-000000000000";
        }
        tavern.questActive = [NSNumber numberWithBool:state.worldBossActive];
        tavern.questKey = state.worldBossKey;
        tavern.questHP = [NSNumber numberWithLong:state.worldBossHealth];
        tavern.questRage = [NSNumber numberWithLong:state.worldBossRage];
        [self.networkIndicatorController endNetworking];
        if (successBlock) {
            successBlock();
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleNetworkError:operation withError:error];
        if (errorBlock) {
            errorBlock();
        }
        [self.networkIndicatorController endNetworking];
        return;
    }];
}

- (void)displayNetworkError {
    [ToastManager showWithText:NSLocalizedString(@"Couldn't connect to the server. Check your network connection", nil) color:ToastColorRed];

}

- (void)displayServerError {
    [ToastManager showWithText:NSLocalizedString(@"There seems to be a problem with the server. Try again later", nil) color:ToastColorRed];

}

- (void)displayError:(NSString *)message {
    [ToastManager showWithText:message color:ToastColorRed];
}

- (void)displayTaskSuccessNotification:(NSNumber *)healthDiff
                    withExperienceDiff:(NSNumber *)expDiff
                          withGoldDiff:(NSNumber *)goldDiff
                         withMagicDiff:(NSNumber *)magicDiff
                         withQuestDamage:(NSNumber *)questDamage {
    ToastColor notificationColor = ToastColorGreen;
    if ([healthDiff intValue] < 0) {
        notificationColor = ToastColorRed;
    }
    if (![self.user hasClassSelected]) {
        magicDiff = @0;
    }
    ToastView *toastView = [[ToastView alloc] initWithHealthDiff:healthDiff.floatValue
                                                       magicDiff:magicDiff.floatValue
                                                         expDiff:expDiff.floatValue
                                                        goldDiff:goldDiff.floatValue
                                                     questDamage:questDamage.floatValue
                                                      background:notificationColor];
    [ToastManager showWithToast:toastView];
}

- (void)displayArmoireNotification:(NSString *)type
                           withKey:(NSString *)key
                          withText:(NSString *)text
                         withValue:(NSNumber *)value {
    if ([type isEqualToString:@"experience"]) {
        [ToastManager showWithText:[text stringByStrippingHTML] color:ToastColorYellow];
    } else if ([type isEqualToString:@"food"]) {
        [self getImage:[NSString stringWithFormat:@"Pet_Food_%@", key]
            withFormat:@"png"
             onSuccess:^(UIImage *image) {
                 ToastView *toastView = [[ToastView alloc] initWithTitle:[[text stringByStrippingHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] icon:image background:ToastColorGray];
                 [ToastManager showWithToast:toastView];
            } onError:^(){}];
    } else if ([type isEqualToString:@"gear"]) {
        [self getImage:[NSString stringWithFormat:@"shop_%@", key]
            withFormat:@"png"
            onSuccess:^(UIImage *image) {
                ToastView *toastView = [[ToastView alloc] initWithTitle:[[text stringByStrippingHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] icon:image background:ToastColorGray];
                [ToastManager showWithToast:toastView];
            } onError:^(){}];
    }
}

- (void)displayLevelUpNotification {
    [self fetchUser:nil onError:nil];

    if ([self.user.level integerValue] >= 10 && ![self.user.preferences.disableClass boolValue] && ![self.user.flags.classSelected boolValue]) {
        HRPGAppDelegate *del = (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *activeViewController = del.window.visibleViewController;
        UINavigationController *selectClassNavigationController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SelectClassNavigationController"];
        selectClassNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [activeViewController presentViewController:selectClassNavigationController
                                           animated:YES
                                         completion:^(){}];
    } else {
        NSArray *nibViews =
        [[NSBundle mainBundle] loadNibNamed:@"HRPGImageOverlayView" owner:self options:nil];
        HRPGImageOverlayView *overlayView = [nibViews objectAtIndex:0];
        overlayView.imageWidth = 140;
        overlayView.imageHeight = 147;
        [self.user setAvatarSubview:overlayView.imageView
                    showsBackground:YES
                         showsMount:YES
                           showsPet:YES];
        overlayView.titleText = NSLocalizedString(@"You gained a level!", nil);
        overlayView.descriptionText = [NSString
                                       stringWithFormat:
                                       NSLocalizedString(
                                                         @"By accomplishing your real-life goals, you've grown to Level %ld!", nil),
                                       (long)([self.user.level integerValue])];
        overlayView.dismissButtonText = NSLocalizedString(@"Huzzah!", nil);
        UIImageView *__weak weakAvatarView = overlayView.imageView;
        overlayView.shareAction = ^() {
            HRPGAppDelegate *del = (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
            UIViewController *activeViewController =
            del.window.rootViewController.presentedViewController;
            [HRPGSharingManager shareItems:@[
                                             [[NSString
                                               stringWithFormat:
                                               NSLocalizedString(
                                                                 @"I got to level %ld in Habitica by improving my real-life habits!",
                                                                 nil),
                                               (long)([self.user.level integerValue])]
                                              stringByAppendingString:@" https://habitica.com/social/level-up"],
                                             [weakAvatarView pb_takeScreenshot]
                                             ]
              withPresentingViewController:activeViewController
             withSourceView:nil];
        };
        [overlayView sizeToFit];

        KLCPopup *popup = [KLCPopup popupWithContentView:overlayView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];

        [popup show];
    }
}

- (void)displaySpellNotification:(NSInteger)manaDiff
                   withSpellname:(NSString *)spellName {
    NSString *content = [NSString stringWithFormat:NSLocalizedString(@"You use %@", nil), spellName];
    ToastView *toastView = [[ToastView alloc] initWithTitle:content rightIcon:HabiticaIcons.imageOfMagic rightText:[NSString stringWithFormat:@"-%ld", (long)manaDiff] rightTextColor:[UIColor blue10] background:ToastColorBlue];
    [ToastManager showWithToast:toastView];
}

- (void)displayRewardNotification:(NSNumber *)goldDiff {
    ToastView *toastView = [[ToastView alloc] initWithTitle:NSLocalizedString(@"Purchased Reward", nil) rightIcon:HabiticaIcons.imageOfGold rightText:[goldDiff stringValue] rightTextColor:[UIColor yellow5] background:ToastColorGray];
    [ToastManager showWithToast:toastView];
}

- (void)displayItemBoughtNotification:(NSNumber *)goldDiff withText:(NSString *)text {
    ToastView *toastView = [[ToastView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Purchased %@", nil), text] rightIcon:HabiticaIcons.imageOfGold rightText:[goldDiff stringValue] rightTextColor:[UIColor yellow5] background:ToastColorGray];
    [ToastManager showWithToast:toastView];
}

- (void)displayDropNotification:(NSString *)key
                       withName:(NSString *)name
                       withType:(NSString *)type
                       withNote:(NSString *)note {
    NSString *description;
    if (name == nil) {
        description = [NSString stringWithFormat:NSLocalizedString(@"You found %@!", nil), key];
    } else if ([[type lowercaseString] isEqualToString:@"food"]) {
        description = [NSString stringWithFormat:NSLocalizedString(@"You found %@!", nil), name];
    } else {
        description = [NSString stringWithFormat:NSLocalizedString(@"You found a %@ %@!", nil), name, type];
    }
    [self getImage:[NSString stringWithFormat:@"Pet_%@_%@", type, key]
        withFormat:@"png"
         onSuccess:^(UIImage *image) {
             ToastView *toastView = [[ToastView alloc] initWithTitle:description icon:image background:ToastColorGray];
             [ToastManager showWithToast:toastView];
        } onError:nil];
}

- (void)displayPurchaseNotification:(NSString *)text
                       withImage:(NSString *)imageName {
    if (imageName) {
    [self getImage:imageName
        withFormat:@"png"
         onSuccess:^(UIImage *image) {
             ToastView *toastView = [[ToastView alloc] initWithTitle:text icon:image background:ToastColorBlue];
             [ToastManager showWithToast:toastView];
         } onError:nil];
    } else {
        [ToastManager showWithText:text color:ToastColorBlue];
    }
}

- (void)displayMountRaisedNotification:(Pet *)mount {
    [mount getMountImage:^(UIImage *image) {
        NSArray *nibViews =
            [[NSBundle mainBundle] loadNibNamed:@"HRPGImageOverlayView" owner:self options:nil];
        HRPGImageOverlayView *overlayView = nibViews[0];
        [overlayView displayImage:image];
        overlayView.imageWidth = 105;
        overlayView.imageHeight = 105;
        overlayView.titleText = NSLocalizedString(@"You raised a mount!", nil);
        overlayView.descriptionText = [NSString
            stringWithFormat:NSLocalizedString(
                                 @"By completing your tasks, you've earned a faithful steed!", nil),
                             (long)([self.user.level integerValue])];
        overlayView.dismissButtonText = NSLocalizedString(@"Huzzah!", nil);
        overlayView.shareAction = ^() {
            HRPGAppDelegate *del = (HRPGAppDelegate *)[UIApplication sharedApplication].delegate;
            UIViewController *activeViewController =
                del.window.rootViewController.presentedViewController;
            [HRPGSharingManager shareItems:@[
                [[NSString
                    stringWithFormat:NSLocalizedString(@"I just gained a %@ mount in Habitica by "
                                                       @"completing my real-life tasks!",
                                                       nil),
                                     mount.niceMountName]
                    stringByAppendingString:@" https://habitica.com/social/raise-mount"],
                image
            ]
                withPresentingViewController:activeViewController
             withSourceView:nil];
        };
        [overlayView sizeToFit];

        KLCPopup *popup = [KLCPopup popupWithContentView:overlayView
                                                showType:KLCPopupShowTypeBounceIn
                                             dismissType:KLCPopupDismissTypeBounceOut
                                                maskType:KLCPopupMaskTypeDimmed
                                dismissOnBackgroundTouch:YES
                                   dismissOnContentTouch:NO];
        [popup show];
    }];
}

- (void)displayNoGemAlert {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController =
        [storyboard instantiateViewControllerWithIdentifier:@"PurchaseGemNavController"];
    UIViewController *viewController =
        [UIApplication sharedApplication].keyWindow.rootViewController;
    [viewController presentViewController:navigationController animated:YES completion:nil];
}

- (void)displayMysteryItemNotification:(Gear *)gear {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest
     setEntity:[NSEntityDescription entityForName:@"Gear" inManagedObjectContext:[self getManagedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"key == %@", gear.key]];
    NSArray *fetchedItem = [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    NSString *mysteryItemText = nil;
    if (fetchedItem.count > 0) {
        Gear *mysteryItem = fetchedItem[0];
        mysteryItemText = mysteryItem.text;
    } else {
        mysteryItemText = NSLocalizedString(@"Mystery Item", nil);
    }
    [self getImage:[NSString stringWithFormat:@"shop_%@", gear.key]
        withFormat:@"png"
         onSuccess:^(UIImage *image) {
             ToastView *toastView = [[ToastView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"You received a %@", nil), mysteryItemText] icon:image background:ToastColorBlue];
             [ToastManager showWithToast:toastView];
         } onError:nil];
}

- (void)displayTransformationItemNotification:(NSString *)itemName withImage:(NSString *)imageName {
    [self getImage:[@"shop_" stringByAppendingString:imageName] withFormat:@"png" onSuccess:^(UIImage *image) {
        ToastView *toastView = [[ToastView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"You used %@", nil), itemName] icon:image background:ToastColorBlue];
        [ToastManager showWithToast:toastView];
    } onError:nil];
}

- (User *)getUser {
    return self.user;
}

- (void)getImage:(NSString *)imageName
      withFormat:(NSString *)format
       onSuccess:(void (^)(UIImage *image))successBlock
         onError:(void (^)())errorBlock {
    if (format == nil) {
        format = @"png";
    }

    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    [manager
        requestImageWithURL:[NSURL
                                URLWithString:[NSString stringWithFormat:@"https://"
                                                                         @"habitica-assets.s3."
                                                                         @"amazonaws.com/"
                                                                         @"mobileApp/images/%@.%@",
                                                                         imageName, format]]
        options:0
        progress:nil
        transform:^UIImage *_Nullable(UIImage *_Nullable image, NSURL *_Nonnull url) {
            return [YYImage imageWithData:[image yy_imageDataRepresentation] scale:1.0];
        }
        completion:^(UIImage *_Nullable image, NSURL *_Nonnull url, YYWebImageFromType from,
                     YYWebImageStage stage, NSError *_Nullable error) {
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(image);
                });
            } else {
                if (errorBlock) {
                    errorBlock();
                }
                NSLog(@"%@: %@", imageName, error);
            }

        }];
}

- (void)setImage:(NSString *)imageName
      withFormat:(NSString *)format
          onView:(UIImageView *)imageView {
    imageView.image = [UIImage imageNamed:@"Placeholder"];
    [self getImage:imageName
        withFormat:format
         onSuccess:^(UIImage *image) {
             imageView.image = image;
         }
           onError:nil];
}

- (UIImage *)getCachedImage:(NSString *)imageName {
    UIImage *image = [[YYImageCache sharedCache] getImageForKey:imageName];
    if (image) {
        return image;
    } else {
        return nil;
    }
}

- (void)setCachedImage:(UIImage *)image
              withName:(NSString *)imageName
             onSuccess:(void (^)())successBlock {
    [[YYImageCache sharedCache] setImage:image forKey:imageName];
    successBlock();
}

- (void)changeUseAppBadge:(BOOL)newUseAppBadge {
    self.useAppBadge = newUseAppBadge;
}

- (void)handleNotifications:(NSArray *)notifications {
    [self.notificationManager enqueueNotifications:notifications];
}

- (void)handleNetworkError:(RKObjectRequestOperation *)operation withError:(NSError *)error {
    RKErrorMessage *errorMessage = [error userInfo][RKObjectMapperErrorObjectsKey][0];
    if (operation.HTTPRequestOperation.response.statusCode == 503) {
        [self displayServerError];
    } else if (errorMessage) {
        [self displayError:errorMessage.errorMessage];
    } else {
        [self displayNetworkError];
    }
}

- (void)insertSubscriberShopItems {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest
     setEntity:[NSEntityDescription entityForName:@"Shop"
                           inManagedObjectContext:[self getManagedObjectContext]]];
    NSArray *existingShops =
    [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    Shop *market = nil;
    
    for (Shop *shop in existingShops) {
        if ([shop.identifier isEqualToString:@"market"]) {
            market = shop;
            break;
        }
    }
    
    if (!market) {
        market = [NSEntityDescription insertNewObjectForEntityForName:@"Shop" inManagedObjectContext:[self getManagedObjectContext]];
        market.identifier = @"market";
        [[self getManagedObjectContext] saveToPersistentStore:&error];
    }
    
    fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest
     setEntity:[NSEntityDescription entityForName:@"ShopCategory"
                           inManagedObjectContext:[self getManagedObjectContext]]];
    NSArray *existingCategories =
    [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];

    ShopCategory *specialCategory = nil;
    
    for (ShopCategory *category in existingCategories) {
        if ([category.identifier isEqualToString:@"special"]) {
            specialCategory = category;
            break;
        }
    }
    
    if (!specialCategory) {
        specialCategory = [NSEntityDescription insertNewObjectForEntityForName:@"ShopCategory" inManagedObjectContext:[self getManagedObjectContext]];
        specialCategory.text = NSLocalizedString(@"Special", nil);
        specialCategory.identifier = @"special";
        specialCategory.index = @99;
    }
    NSMutableOrderedSet *categories = [NSMutableOrderedSet orderedSetWithOrderedSet:market.categories];
    [categories addObject:specialCategory];
    market.categories = categories;
    specialCategory.shop = market;
    [[self getManagedObjectContext] saveToPersistentStore:&error];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest
     setEntity:[NSEntityDescription entityForName:@"ShopItem"
                           inManagedObjectContext:[self getManagedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isSubscriberItem = YES"]];
    NSArray *existingItems =
    [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];

    ShopItem *gem = nil;
    
    for (ShopItem *item in existingItems) {
        if ([item.key isEqualToString:@"gem"]) {
            gem = item;
            break;
        }
    }
    
    if (!gem) {
        gem = [NSEntityDescription insertNewObjectForEntityForName:@"ShopItem" inManagedObjectContext:[self getManagedObjectContext]];
        gem.key = @"gem";
        gem.text = NSLocalizedString(@"Gem", nil);
        gem.notes = NSLocalizedString(@"Because you subscribe to Habitica, you can purchase a number of Gems each month using Gold.", nil);
        gem.imageName = @"gem_shop";
        gem.purchaseType = @"gems";
        gem.currency = @"gold";
        gem.value = @20;
        gem.isSubscriberItem = @YES;
    }

    gem.itemsLeft = [NSNumber numberWithInteger:self.user.subscriptionPlan.gemsLeft];
    
    NSMutableOrderedSet *items = [NSMutableOrderedSet orderedSetWithOrderedSet:specialCategory.items];
    
    [items addObject:gem];
    
    specialCategory.items = items;
    
    gem.category = specialCategory;
    
    [[self getManagedObjectContext] saveToPersistentStore:&error];
}

- (void) updateMysteryItemCount {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest
     setEntity:[NSEntityDescription entityForName:@"Item"
                           inManagedObjectContext:[self getManagedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isSubscriberItem = YES"]];
    NSArray *existingItems = [[self getManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    Item *mysteryPresent = nil;
    
    for (Item *item in existingItems) {
        if ([item.key isEqualToString:@"inventory_present"]) {
            mysteryPresent = item;
            break;
        }
    }
    
    if (!mysteryPresent) {
        mysteryPresent = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[self getManagedObjectContext]];
        mysteryPresent.key = @"inventory_present";
        mysteryPresent.text = NSLocalizedString(@"Mystery Item", nil);
        mysteryPresent.notes = NSLocalizedString(@"Each month, subscribers will receive a mystery item. This is usually released about one week before the end of the month.", nil);
        mysteryPresent.isSubscriberItem = @YES;
        mysteryPresent.type = @"special";
    }
    mysteryPresent.owned = self.user.subscriptionPlan.mysteryItemCount;
}

@end
