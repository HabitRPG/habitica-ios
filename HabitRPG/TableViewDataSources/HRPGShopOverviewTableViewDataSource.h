//
//  HRPGShopOverviewTableViewDataSource.h
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HRPGShopOverviewTableViewDataSourceDelegate <NSObject>
@property (nonatomic) NSDictionary * _Nullable shopDictionary;
- (NSString * _Nullable)identifierAtIndex:(long)index;
- (void)refreshShopWithIdentifier:(NSString * _Nonnull)identifier;
@end

@interface HRPGShopOverviewTableViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak, nullable) id<HRPGShopOverviewTableViewDataSourceDelegate> delegate;

+ (NSDictionary * _Nonnull)shopNames;
@end
