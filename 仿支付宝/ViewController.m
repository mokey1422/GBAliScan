//
//  ViewController.m
//  仿支付宝
//
//  Created by 张国兵 on 15/12/9.
//  Copyright © 2015年 zhangguobing. All rights reserved.
//
#import "Masonry.h"
#import "ViewController.h"
#import "Scan_VC.h"
#import "QRCodeGenerator.h"
#import "ZXingObjC.h"
#define iOS8 [[UIDevice currentDevice].systemVersion floatValue] >= 8.0
#define RandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1]
#define DEFAULT 0
@interface ViewController ()<UITextFieldDelegate>{
   
    NSTimer*_timer;
    
}
@property(nonatomic,strong)UIButton*scanBtn;
@property(nonatomic,strong)UITextField*textField;
@property(nonatomic,strong)UIButton*creatBtn;
@property(nonatomic,strong)UIImageView*outImageView;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=NO;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"原生二维码扫描-支付宝效果";
    /**
     *  ios7之前我们实现二维码扫描一般是借助第三方来实现，但是在ios7之后系统自己提供二维码扫面的方法，而且用原生的方法性能要比第三方的要好很多，今天就写个小的demo来介绍一下系统的原生二维码扫描实现的过程
     *  部分代码借鉴高少东的支付宝开源项目做了一下整理和优化
     *  二维码参考样式无非就是支付宝和微信两大巨头的样式，今天仿写一下支付宝的二维码扫描
     *
     *  顺便熟悉一下 masonry
     *
     */
    //1.
    _scanBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_scanBtn setTitle:@"scan" forState:UIControlStateNormal];
    [_scanBtn setBackgroundColor:[UIColor orangeColor]];
    [_scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanBtn];
    //2.
    _creatBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_creatBtn setTitle:@"create" forState:UIControlStateNormal];
    [_creatBtn setBackgroundColor:[UIColor orangeColor]];
    [_creatBtn addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_creatBtn];
    //3.
    _outImageView=[[UIImageView alloc]init];
    _outImageView.layer.borderWidth=2.0f;
    _outImageView.layer.borderColor=[UIColor redColor].CGColor;
    _outImageView.userInteractionEnabled=YES;
    UIImage *image=[UIImage imageNamed:@"6824500_006_thumb.jpg"];
#ifdef DEFAULT
    /**普通默认黑色 */
     UIImage*tempImage=[QRCodeGenerator qrImageForString:@"sssssssss" imageSize:360 Topimg:image];
  
#else
    /**彩色二维码 */
   
      UIImage*tempImage=[QRCodeGenerator qrImageForString:@"ssssss" imageSize:360 Topimg:image withColor:RandomColor];
#endif
    
    _outImageView.image=tempImage;
    _outImageView.contentMode=UIViewContentModeScaleToFill;
    UILongPressGestureRecognizer*longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(dealLongPress:)];
    [_outImageView addGestureRecognizer:longPress];
    [self.view addSubview:_outImageView];
    //4.
    _textField = [[UITextField alloc] init];
    _textField.placeholder =@"  请输入二维码内容";
    _textField.delegate = self;
    _textField.layer.masksToBounds = YES;
    _textField.returnKeyType=UIReturnKeyDefault;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.font = [UIFont boldSystemFontOfSize:15.0];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_textField];

    //5.定时器
    _timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(create) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    
    
    
}
#pragma mark-> 布局
-(void)viewDidLayoutSubviews{
    
    __weak __typeof(self)weakSelf  = self;
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(100);
        make.right.mas_equalTo(-10);
        make.left.mas_equalTo(10);
        make.height.mas_equalTo(80);
    
    }];
    
    [_scanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(weakSelf.textField.mas_bottom).offset(10);
        make.bottom.mas_equalTo(weakSelf.outImageView.mas_top).offset(-10);
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(weakSelf.creatBtn.mas_left).offset(-10);
        make.height.mas_equalTo(80);
    }];
    
    [_creatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.top.bottom.mas_equalTo(weakSelf.scanBtn);
        make.right.mas_equalTo(-10);
        make.left.mas_equalTo(weakSelf.scanBtn.mas_right).offset(10);
    }];
    
    [_outImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(weakSelf.creatBtn.mas_bottom).offset(10);
        make.bottom.mas_equalTo(-10);
        
        
    }];
    
}
#pragma mark-> 二维码扫描
-(void)scan{
    
    Scan_VC*vc=[[Scan_VC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark-> 二维码生成
-(void)create{
    
    UIImage *image=[UIImage imageNamed:@"6824500_006_thumb.jpg"];
    NSString*tempStr;
    if(self.textField.text.length==0){
        
        tempStr=@"ddddddddd";
        
    }else{
        
        tempStr=self.textField.text;
        
    }
    UIImage*tempImage=[QRCodeGenerator qrImageForString:tempStr imageSize:360 Topimg:image withColor:RandomColor];

    _outImageView.image=tempImage;
    
}

#pragma mark-> 长按识别二维码
-(void)dealLongPress:(UIGestureRecognizer*)gesture{
    
    if(gesture.state==UIGestureRecognizerStateBegan){
        
        _timer.fireDate=[NSDate distantFuture];
        
        UIImageView*tempImageView=(UIImageView*)gesture.view;
        if(tempImageView.image){
            

            if(iOS8){
    
                /**ios8环境以上 */
                 //初始化一个监测器
                CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
                
                CGImageRef imageToDecode=tempImageView.image.CGImage;
                //监测到的结果数组
                NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:imageToDecode]];
                if (features.count >=1) {
                    /**结果对象 */
                    CIQRCodeFeature *feature = [features objectAtIndex:0];
                    NSString *scannedResult = feature.messageString;
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];

                }
                else{
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                }

                
                
            }else{
            
            CGImageRef imageToDecode=tempImageView.image.CGImage;
            
            ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
            ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
            
            NSError *error = nil;
            
            ZXDecodeHints *hints = [ZXDecodeHints hints];
            /**识别器 */
            ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
            ZXResult *result = [reader decode:bitmap
                                        hints:hints
                                        error:&error];
            if (result) {
                
                NSString *contents = result.text;
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:contents delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                /**扫描到的类型-> */
                ZXBarcodeFormat format = result.barcodeFormat;
                NSLog(@"%d",format);
            } else {
                
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }
        
        
    }else if (gesture.state==UIGestureRecognizerStateEnded){
        
        
        _timer.fireDate=[NSDate distantPast];
    }
    
    
}
}
#pragma mark->textFiel delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    _timer.fireDate=[NSDate distantFuture];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    _timer.fireDate=[NSDate distantPast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
