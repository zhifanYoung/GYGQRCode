//
//  GYGQRCode.m
//  QRCode
//
//  Created by Young on 16/3/28.
//  Copyright © 2016年 Young. All rights reserved.
//

#import "GYGQRCode.h"
#import <AVFoundation/AVFoundation.h>

@interface GYGQRCode () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *animationImage;

@property (nonatomic, strong) AVCaptureSession *mySession;

@property (nonatomic, strong) AVCaptureDeviceInput *inPut;

@property (nonatomic, strong) AVCaptureMetadataOutput *outPut;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) CALayer *drawLayer;

@property (nonatomic, strong) CIDetector *detector;

@end

#define kMainScreenW [UIScreen mainScreen].bounds.size.width
#define kMainScreenH [UIScreen mainScreen].bounds.size.height
#define kW 300/kMainScreenW
#define kH 300/kMainScreenH
#define kX (kMainScreenW-300)/2/kMainScreenW
#define kY (kMainScreenH-300)/2/kMainScreenH

@implementation GYGQRCode

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupContainer];
    
    [self scan];
}

- (void)scan {
    
    if (![self.mySession canAddInput:self.inPut]) return;
    if (![self.mySession canAddOutput:self.outPut]) return;
    [self.mySession addInput:self.inPut];
    [self.mySession addOutput:self.outPut];
    self.outPut.metadataObjectTypes = self.outPut.availableMetadataObjectTypes;
    [self.outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.mySession startRunning];
    [self.view.layer insertSublayer:self.drawLayer atIndex:0];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // 设置扫描的有效区域 X Y 互换 W H 互换 , 原点在右上角 （0, 0, 0.5, 0.5）
    [self.outPut setRectOfInterest:CGRectMake(kY, kX, kH, kW)];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        [self.mySession stopRunning];
        [self.navigationController popViewControllerAnimated:YES];
        [self analyseScanResult:obj.stringValue];
    }
}

#pragma mark - response

- (IBAction)cameraBtnClicked:(UIBarButtonItem *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scannedResult = feature.messageString;
        
        [self.navigationController popViewControllerAnimated:YES];
        [self analyseScanResult:scannedResult];
    }
}

- (void)analyseScanResult:(NSString *)result {

    if (self.scanBlock) {
        self.scanBlock(result);
    }
}

- (void)setupContainer {

    NSTimer *animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(barAnimation) userInfo:nil repeats:MAXFLOAT];
    [animationTimer fire];
}

- (void)barAnimation {
    
    self.animationImage.hidden = !self.animationImage.hidden;
}

#pragma mark - getter

- (AVCaptureSession *)mySession {

    if (!_mySession) {
        _mySession = [[AVCaptureSession alloc] init];
    }
    return _mySession;
}

- (AVCaptureMetadataOutput *)outPut {

    if (!_outPut) {
        _outPut = [[AVCaptureMetadataOutput alloc] init];
    }
    return _outPut;
}

- (AVCaptureDeviceInput *)inPut {

    if (!_inPut) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device == nil) return nil;
        _inPut = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _inPut;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {

    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.mySession];
        _previewLayer.frame = self.view.bounds;
    }
    return _previewLayer;
}

- (CALayer *)drawLayer {

    if (!_drawLayer) {
        
        _drawLayer = [CALayer layer];
        _drawLayer.frame = self.view.bounds;
    }
    return _drawLayer;
}

- (CIDetector *)detector {

    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    }
    return _detector;
}
@end
