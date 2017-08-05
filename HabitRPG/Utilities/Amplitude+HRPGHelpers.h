//
//  Amplitude+HRPGHelpers.h
//  Habitica
//
//  Created by Elliot Schrock on 7/31/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

#import <Amplitude_iOS/Amplitude.h>

@interface Amplitude (HRPGHelpers)

- (void)logNavigateEventForClass:(NSString *)className;

@end
