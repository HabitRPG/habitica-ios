//
//  HRPGQRCodeScannerViewController.h
//  Habitica
//
//  Created by Phillip Thelen on 08/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface HRPGQRCodeScannerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

- (BOOL) isCameraAvailable;
- (void) startScanning;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

@property NSString *scannedCode;

@end
