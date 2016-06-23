//
//  SYQrCodeScanne.m
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/6.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import "SYQrCodeScanne.h"
#import <AVFoundation/AVFoundation.h>

#define SYScreenWidth [UIScreen mainScreen].bounds.size.width
#define SYScreenHigh [UIScreen mainScreen].bounds.size.height

#define scanneArea 230

#define SYScanne_Line_Tag 57976

#define SYCenter_Tag 238374

@interface SYQrCodeScanne () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) CALayer *layer;

@property (nonatomic, assign) BOOL torchIsOn;

@end

@implementation SYQrCodeScanne

/**
 *  进行扫描
 */
- (void)scanning
{
    [[[[UIApplication sharedApplication]keyWindow]rootViewController] presentViewController:self animated:NO completion:nil];
}

- (void)onBackClick
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self openScanning];
}

//创建界面
- (void)createUI
{
    //上下两部分高度
    CGFloat height = (SYScreenHigh-scanneArea)/2;
    
    //左右两部分宽度
    CGFloat width = (SYScreenWidth-scanneArea)/2;
    
    //顶部蒙版
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SYScreenWidth, height)];
    topView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:topView];
    
    //左部蒙版
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, scanneArea)];
    leftView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:leftView];
    
    //右部蒙版
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(SYScreenWidth-width, height, width, scanneArea)];
    rightView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:rightView];
    
    //底部蒙版
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SYScreenHigh-height, SYScreenWidth, height)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:bottomView];
    
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 44, 44);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    //扫描框
    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scanneArea, scanneArea)];
    centerView.tag = SYCenter_Tag;
    centerView.center = self.view.center;
    centerView.image = [UIImage imageNamed:@"扫描框"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerView];
    
    
    //扫描线
    UIImageView *scanneLine = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(centerView.frame), CGRectGetMaxY(topView.frame), scanneArea, 3)];
    scanneLine.tag = SYScanne_Line_Tag;
    [scanneLine setImage:[UIImage imageNamed:@"扫描线"]];
    [self.view addSubview:scanneLine];
    
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, centerView.frame.origin.y-80, SYScreenWidth, 60)];
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 0;
    title.text = @"将二维码置入框中，即可自动扫描";
    [self.view addSubview:title];
    
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake(CGRectGetMinX(centerView.frame), CGRectGetMaxY(centerView.frame)+30, 40, 40);
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"photoImage"] forState:UIControlStateNormal];
    photoBtn.layer.cornerRadius = 20;
    photoBtn.clipsToBounds = YES;
    photoBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    photoBtn.layer.borderWidth = 1;
    [photoBtn addTarget:self action:@selector(onPhotoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photoBtn];
    
    
    
    UIButton *openFlashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openFlashBtn.frame = CGRectMake(CGRectGetMaxX(centerView.frame)-40, CGRectGetMaxY(centerView.frame)+30, 40, 40);
    openFlashBtn.layer.cornerRadius = 20;
    openFlashBtn.clipsToBounds = YES;
    openFlashBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    openFlashBtn.layer.borderWidth = 1;
    [openFlashBtn setBackgroundImage:[UIImage imageNamed:@"85923"] forState:UIControlStateNormal];
    [openFlashBtn setBackgroundImage:[UIImage imageNamed:@"85923Select"] forState:UIControlStateSelected];
    [openFlashBtn addTarget:self action:@selector(onOpenFlashClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openFlashBtn];
    
}

//打开闪光灯
- (void)onOpenFlashClick:(UIButton *)sender
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!sender.selected) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                sender.selected = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                sender.selected = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

//打开相册
- (void)onPhotoClick
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
//    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

//图像选取器的委托方法，选完图片后回调该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //当图片不为空时显示图片并保存图片
    if (image != nil) {
        //使用图片
        NSNumber *orientation = [NSNumber numberWithInt:[image imageOrientation]];
        NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];
        CIImage *ciImage = [CIImage imageWithCGImage:[image CGImage] options:imageOptions];
        
        
        // 2.从选中的图片中读取二维码数据
        // 2.1创建一个探测器
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:nil] options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        
        // 2.2利用探测器探测数据
        NSArray *features = [detector featuresInImage:ciImage];
        
        if (features.count) {
            for (CIFeature *feature in features) {
                if ([feature isKindOfClass:[CIQRCodeFeature class]]) {
                    [self scanningFinshedWithString:((CIQRCodeFeature *)feature).messageString];
                    break;
                }
            }
        } else {
            NSLog(@"未正常解析二维码图片, 请确保iphone5/5c以上的设备");
            if (_scanneScusseBlock) {
                 _scanneScusseBlock(SYCodeTypeUnknow ,nil);
            }
            [self onBackClick];
        }
    }
    
}



/**
 *  开启扫描
 */
- (void)openScanning
{
    // 1.创建捕捉会话
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    NSError *error = nil;
    // 2.添加输入设备(数据从摄像头输入)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    if ([session canAddInput:input ]){
        [session addInput:input ];
    }
    
    self.session = session;
    
    //添加输出数据
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [output setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //限制扫描范围
    [output setRectOfInterest:CGRectMake (((SYScreenHigh - scanneArea)/2)/SYScreenHigh, ((SYScreenWidth - scanneArea)/2)/SYScreenWidth, scanneArea/SYScreenHigh, scanneArea/SYScreenWidth)];
    
    if ([session canAddOutput:output ]){
        [session addOutput:output];
    }
    
    // 3.1.设置输入元数据的类型(类型是二维码与条形码数据)
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
//                                     AVMetadataObjectTypeEAN13Code,
//                                     AVMetadataObjectTypeEAN8Code,
//                                     AVMetadataObjectTypeCode128Code]];
    
    // 4.添加扫描图层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = CGRectMake(0, 0, SYScreenWidth, SYScreenHigh);
    [self.view.layer insertSublayer:layer atIndex:0];
    [self.view.layer addSublayer:layer];
    self.layer = layer;
    
    [self createUI];
    
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];

    // 5.开始扫描
    [session startRunning];
}



// 当扫描到数据时就会执行该方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        //获取扫描结果
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        
        // 停止扫描
        [self.session stopRunning];
        [self.layer removeFromSuperlayer];
        
        [self scanningFinshedWithString:object.stringValue];
        
    } else {
        NSLog(@"二维码解析失败");
        if (_scanneScusseBlock) {
            _scanneScusseBlock(SYCodeTypeUnknow ,nil);
        }
        [self onBackClick];
    }
}

/**
 *  扫描结束
 */
- (void)scanningFinshedWithString:(NSString *)stringValue
{
    if (_scanneScusseBlock){
        
        SYCodeType codeType = SYCodeTypeString;
        
        if (!stringValue || (NSNull *)stringValue == [NSNull null]){
            codeType = SYCodeTypeUnknow;
        }
        
        if ([stringValue hasPrefix:@"http://"] ||
            [stringValue hasPrefix:@"https://"]) {
            codeType = SYCodeTypeLink;
        }
        _scanneScusseBlock(codeType ,stringValue);
    }else{
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:stringValue]];
    }
    [self onBackClick];
}


/**
 *  监听扫描状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addScanneAnimation];
        }else{
            [self removeScanneAnimation];
        }
    }
}


/**
 *  添加扫码动画
 */
- (void)addScanneAnimation
{
    UIView *scanneLine = [self.view viewWithTag:SYScanne_Line_Tag];
    UIView *centerView = [self.view viewWithTag:SYCenter_Tag];
    
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:[NSNumber numberWithFloat:0]];
    [animationMove setToValue:[NSNumber numberWithFloat:CGRectGetHeight(centerView.frame)-2.f]];
    animationMove.duration = 3;
    animationMove.delegate = self;
    animationMove.repeatCount  = OPEN_MAX;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [scanneLine.layer addAnimation:animationMove forKey:@"scanneLineAnimation"];
    
}

/**
 *  删除扫码动画
 */
- (void)removeScanneAnimation
{
    UIView *scanneLine = [self.view viewWithTag:SYScanne_Line_Tag];
    [scanneLine.layer removeAnimationForKey:@"scanneLineAnimation"];
}

- (void)dealloc
{
    [self.session removeObserver:self forKeyPath:@"running" context:nil];
}


@end
