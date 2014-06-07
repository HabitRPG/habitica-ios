//
//  Pet.m
//  RabbitRPG
//
//  Created by Phillip on 07/06/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import "Pet.h"
#import "HRPGAppDelegate.h"
#import "HRPGManager.h"

@implementation Pet

@dynamic key;
@dynamic trained;
@dynamic asMount;
@dynamic type;

- (void)setMountOnImageView:(UIImageView *)imageView {
    HRPGAppDelegate *appdelegate = (HRPGAppDelegate *) [[UIApplication sharedApplication] delegate];
    HRPGManager *sharedManager = appdelegate.sharedManager;
    NSString *cachedImageName = [NSString stringWithFormat:@"%@_Mount", self.key];
    UIImage *cachedImage;
    cachedImage = [sharedManager getCachedImage:cachedImageName];
    if (cachedImage) {
        imageView.image = cachedImage;
        return;
    }
    __block UIImage *currentMount = nil;
    __block UIImage *currentMountHead = nil;
    dispatch_group_t group = dispatch_group_create();

    
    dispatch_group_enter(group);
    [sharedManager getImage:[NSString stringWithFormat:@"Mount_Head_%@", self.key] onSuccess:^(UIImage *image) {
        currentMountHead = image;
        dispatch_group_leave(group);
    } onError:^() {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [sharedManager getImage:[NSString stringWithFormat:@"Mount_Body_%@", self.key] onSuccess:^(UIImage *image) {
        currentMount = image;
        dispatch_group_leave(group);
    } onError:^() {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(105, 105), NO, 0.0f);
        [currentMount drawInRect:CGRectMake(0, 0, currentMount.size.width, currentMount.size.height)];
        [currentMountHead drawInRect:CGRectMake(0, 0, currentMountHead.size.width, currentMountHead.size.height)];

        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = resultImage;
        });
        [sharedManager setCachedImage:resultImage withName:cachedImageName onSuccess:^() {
        }];
    });
}

@end
