//
//  Spell.m
//  Habitica
//
//  Created by Phillip Thelen on 19/05/14.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "Spell.h"

@implementation Spell

@dynamic key;
@dynamic klass;
@dynamic level;
@dynamic mana;
@dynamic notes;
@dynamic target;
@dynamic text;

- (void)setKlass:(NSString *)klass {
    [self willChangeValueForKey:@"klass"];
    [self setPrimitiveValue:[klass stringByReplacingOccurrencesOfString:@"data.spells."
                                                             withString:@""]
                     forKey:@"klass"];
    [self didChangeValueForKey:@"klass"];
}

@end
