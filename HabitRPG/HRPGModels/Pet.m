//
//  Pet.m
//  Habitica
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Pet.h"
#import "HRPGManager.h"

@implementation Pet

@dynamic key;
@dynamic trained;
@dynamic asMount;
@dynamic type;
@dynamic nicePetName;
@dynamic niceMountName;

- (void)getMountImage:(void (^)(UIImage *))successBlock {
    NSString *cachedImageName = [NSString stringWithFormat:@"%@_Mount", self.key];
    UIImage *cachedImage;
    cachedImage = [[HRPGManager sharedManager] getCachedImage:cachedImageName];
    if (cachedImage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(cachedImage);
        });
        return;
    }
    __block UIImage *currentMount = nil;
    __block UIImage *currentMountHead = nil;
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [[HRPGManager sharedManager] getImage:[NSString stringWithFormat:@"Mount_Head_%@", self.key]
        withFormat:nil
        onSuccess:^(UIImage *image) {
            currentMountHead = image;
            dispatch_group_leave(group);
        }
        onError:^() {
            dispatch_group_leave(group);
        }];

    dispatch_group_enter(group);
    [[HRPGManager sharedManager] getImage:[NSString stringWithFormat:@"Mount_Body_%@", self.key]
        withFormat:nil
        onSuccess:^(UIImage *image) {
            currentMount = image;
            dispatch_group_leave(group);
        }
        onError:^() {
            dispatch_group_leave(group);
        }];

    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(currentMount.size.width, currentMount.size.height), NO, 0.0f);
        [currentMount
            drawInRect:CGRectMake(0, 0, currentMount.size.width, currentMount.size.height)];
        [currentMountHead
            drawInRect:CGRectMake(0, 0, currentMountHead.size.width, currentMountHead.size.height)];

        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(resultImage);
        });
        if (currentMount && currentMountHead) {
            [[HRPGManager sharedManager] setCachedImage:resultImage
                                 withName:cachedImageName
                                onSuccess:^(){
                                }];
        }
    });
}

- (void)setMountOnImageView:(UIImageView *)imageView {
    [self getMountImage:^(UIImage *image) {
        imageView.image = image;
    }];
}

- (BOOL)likesFood:(Food *)food {
    NSString *type = [self.key componentsSeparatedByString:@"-"][1];
    return [type isEqualToString:food.target];
}

- (void)setType:(NSString *)type {
    [self willChangeValueForKey:@"type"];
    [self setPrimitiveValue:[type stringByReplacingOccurrencesOfString:@"data."
                                                            withString:@""]
                     forKey:@"type"];
    [self didChangeValueForKey:@"type"];
}

- (BOOL)isFeedable {
    return !((self.asMount) || ([self.type isEqualToString:@"specialPets"]));
}

@end
