//
//  Gear.m
//  HabitRPG
//
//  Created by Phillip Thelen on 07/04/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Gear.h"

@implementation Gear

@dynamic con;
@dynamic index;
@dynamic intelligence;
@dynamic klass;
@dynamic per;
@dynamic str;
@dynamic owned;
@dynamic eventStart;
@dynamic eventEnd;
@dynamic specialClass;
@dynamic set;

- (void)willSave {
    if (![self.rewardType isEqualToString:@"gear"]) {
        self.rewardType = @"gear";
    }
}

- (BOOL)isEquippedBy:(User *)user {
    if ([self.type isEqualToString:@"weapon"]) {
        if ([user.equipped.weapon isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"armor"]) {
        if ([user.equipped.armor isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"head"]) {
        if ([user.equipped.head isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"shield"]) {
        if ([user.equipped.shield isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"headAccessory"]) {
        if ([user.equipped.headAccessory isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"back"]) {
        if ([user.equipped.back isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"body"]) {
        if ([user.equipped.body isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"eyewear"]) {
        if ([user.equipped.eyewear isEqualToString:self.key]) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isCostumeOf:(User *)user {
    if ([self.type isEqualToString:@"weapon"]) {
        if ([user.costume.weapon isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"armor"]) {
        if ([user.costume.armor isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"head"]) {
        if ([user.costume.head isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"shield"]) {
        if ([user.costume.shield isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"headAccessory"]) {
        if ([user.costume.headAccessory isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"back"]) {
        if ([user.costume.back isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"body"]) {
        if ([user.costume.body isEqualToString:self.key]) {
            return YES;
        }
    } else if ([self.type isEqualToString:@"eyewear"]) {
        if ([user.costume.eyewear isEqualToString:self.key]) {
            return YES;
        }
    }

    return NO;
}

- (NSString *)getCleanedClassName {
    NSString *className = [self valueForKey:@"klass"];
    if ([className isEqualToString:@"wizard"]) {
        return @"mage";
    }
    return className;
}

-(NSString *)statsText {
    NSMutableArray *statsComponents = [NSMutableArray array];
    if ([self.intelligence intValue] > 0) {
        [statsComponents addObject:[NSString stringWithFormat:NSLocalizedString(@"INT %@", nil), self.intelligence]];
    }
    if ([self.con intValue] > 0) {
        [statsComponents addObject:[NSString stringWithFormat:NSLocalizedString(@"CON %@", nil), self.con]];
    }
    if ([self.str intValue] > 0) {
        [statsComponents addObject:[NSString stringWithFormat:NSLocalizedString(@"STR %@", nil), self.str]];
    }
    if ([self.per intValue] > 0) {
        [statsComponents addObject:[NSString stringWithFormat:NSLocalizedString(@"PER %@", nil), self.per]];
    }
    
    return [statsComponents componentsJoinedByString:@", "];
}

@end
