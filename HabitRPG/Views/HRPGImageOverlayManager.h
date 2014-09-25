//
//  HRPGImageOverlayManager.h
//  RabbitRPG
//
//  Created by viirus on 25/09/14.
//  Copyright (c) 2014 Phillip Thelen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRPGImageOverlayManager : NSObject {
    
}

+ (id)sharedManager;


+ (void)displayImage:(NSString*)image withText:(NSString*)text withNotes:(NSString*)notes;

@end
