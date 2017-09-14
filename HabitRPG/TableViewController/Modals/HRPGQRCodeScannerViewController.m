//
//  HRPGQRCodeScannerViewController.m
//  Habitica
//
//  Created by Phillip Thelen on 08/08/16.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

#import "HRPGQRCodeScannerViewController.h"
#import "NSString+UUID.h"
#import "Habitica-Swift.h"

@interface HRPGQRCodeScannerViewController ()

@property AVCaptureDevice *device;
@property AVCaptureDeviceInput *input;
@property AVCaptureSession *session;
@property AVCaptureMetadataOutput *output;
@property AVCaptureVideoPreviewLayer *preview;


@end

@implementation HRPGQRCodeScannerViewController

- (void)viewWillAppear:(BOOL)animated; {
    [super viewWillAppear:animated];
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    } else {
        [self startScanning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if([self isCameraAvailable]) {
        [self stopScanning];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if([self isCameraAvailable]) {
        [self setupScanner];
    }
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)evt {
    UITouch *touch=[touches anyObject];
    CGPoint pt= [touch locationInView:self.view];
    [self focus:pt];
}

#pragma mark -
#pragma mark NoCamAvailable

- (void) setupNoCameraView {
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = NSLocalizedString(@"No Camera available", nil);
    labelNoCam.textColor = [UIColor blackColor];
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape | UIInterfaceOrientationMaskPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = [self getAVOrientation];
}

#pragma mark -
#pragma mark AVFoundationSetup

- (void) setupScanner {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if (self.input != nil) {
        self.session = [[AVCaptureSession alloc] init];
        
        self.output = [[AVCaptureMetadataOutput alloc] init];
        [self.session addOutput:self.output];
        [self.session addInput:self.input];
        
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        AVCaptureConnection *con = self.preview.connection;
        
        con.videoOrientation = [self getAVOrientation];
        
        [self.view.layer insertSublayer:self.preview atIndex:0];
    }
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL) isCameraAvailable {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)startScanning {
    [self.session startRunning];
    
}

- (void) stopScanning {
    [self.session stopRunning];
}

- (void) setTorch:(BOOL) aStatus {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ( [device hasTorch] ) {
        if ( aStatus ) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
    }
    [device unlockForConfiguration];
}

- (void) focus:(CGPoint) aPoint; {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        if([device lockForConfiguration:nil]) {
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}

- (int) getAVOrientation {
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        return AVCaptureVideoOrientationLandscapeRight;
    } else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {        return AVCaptureVideoOrientationLandscapeLeft;
    } else {
        return AVCaptureVideoOrientationPortrait;
    }
}

#pragma mark -
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if (self.scannedCode == nil) {
                self.scannedCode = [self getScannedUUID:[((AVMetadataMachineReadableCodeObject *) current) stringValue]];
                if ([self.scannedCode isValidUUID]) {
                    [self performSegueWithIdentifier:@"ScannedCodeSegue" sender:self];
                } else {
                    UIAlertController *alertController = [UIAlertController alertWithTitle:NSLocalizedString(@"Invalid Habitica User ID", nil) message:NSLocalizedString(@"The scanned QR-Code did not contain a valid Habitica User ID.", nil) handler:^(UIAlertAction * _Nonnull action) {
                        self.scannedCode = nil;
                    }];
                    [self presentViewController:alertController animated:true completion:nil];
                }
                return;
            }
        }
    }
}

- (NSString *)getScannedUUID:(NSString *)scannedData {
    return [scannedData stringByReplacingOccurrencesOfString:@"https://habitica.com/qr-code/user/" withString:@""];
}

@end
