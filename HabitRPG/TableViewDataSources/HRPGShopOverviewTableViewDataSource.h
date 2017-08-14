//
//  HRPGShopOverviewTableViewDataSource.h
//  Habitica
//
//  Created by Elliot Schrock on 7/29/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HRPGShopOverviewTableViewDataSourceDelegate <NSObject>
- (NSString *)identifierAtIndex:(long)index;
@optional
- (void)needsShopRefreshForIdentifier:(NSString *)identifier at:(NSIndexPath *)indexPath;
@end

@interface HRPGShopOverviewTableViewDataSource : NSObject<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<HRPGShopOverviewTableViewDataSourceDelegate> delegate;
@property (nonatomic) NSDictionary *shopDictionary;

+ (NSDictionary *)shopBgImageNames;
+ (NSDictionary *)shopCharacterImageNames;
+ (NSDictionary *)shopNames;
@end
