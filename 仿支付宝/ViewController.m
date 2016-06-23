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
#import "SYQrCode.h"
#define KLINKSTR @"https://www.baidu.com/link?url=lV1hUtb7iigXGP4d0VcBTUTx4XLopvHysOIU3N3LJvBIWj7MuKzSyU14BAvCkeXgbhDwNpwBEpdUAXmnzeElWa&wd=&eqid=dab5812100009e37000000025731c53d"
#define iOS8 [[UIDevice currentDevice].systemVersion floatValue] >= 8.0
#define ScreenWidth      [UIScreen mainScreen].bounds.size.width
#define RandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1]

#define DEFAULT 0

@interface ViewController ()<UITextFieldDelegate>{
   
    NSTimer*_timer;
    NSInteger _count;
}
@property(nonatomic,strong)UIButton*scanBtn;
@property(nonatomic,strong)UITextField*textField;
@property(nonatomic,strong)UIButton*creatBtn;
@property(nonatomic,strong)UIImageView*outImageView;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
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
     *
     *   顺便熟悉一下 masonry
     *   最近看到别人写的一个生成二维码的玩法，感觉还是不错的，分享给大家，感谢陈密同学的分享，引用别人的代码特此声明，只是纯粹好东西分享，不做商用，如有侵权请告知  Email:13241292557@163.com
     *   内容字符越多描绘的二维码越复杂
     *   之前用过的libqrencode是很早的时候用过的一个三方库其中有一些核心算法是借助于c语言写的，但是苹果现在从IOS5之后就提供了生成二维码的类-->CIFilter,我之前遇到过通过之前的三方生成的二维码不能很好的被系统的识别器识别的问题。
         猜想：如果用系统自己的生成方法去生成的话识别的时候兼容性会不会提高很多，待会我们一起测试一下。
     *   贴上别人的代码分享给大家。
     *   经过测试，识别还是同样的问题，问题在于现在系统只能识别一些简单的图像，对于那些有填充色的图像识别还是不太好用，既然找到了问题我们在识别的时候可不可以暂时恢复成二维码只有黑白的图像，这样我们就可以顺利识别了
     *   经过验证恢复成黑白像只有部分是可以的，看来只有通过逆向推理去一层层解析到之前的二维码内容，做加法是无效的只能做减法。
     *   暂时说这么多，未完待续。。。
     *   以后我会把自定义二维码长按识别的问题解决一下，这一版暂时不去做了还有别的事情，有空我给添加上。
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

#ifdef DEFAULT
    /**普通默认黑色 */
     UIImage*tempImage = [UIImage generateImageWithQrCode:KLINKSTR QrCodeImageSize:0];;
  
#else
    /**彩色二维码 */
   
      UIImage*tempImage = [UIImage generateImageWithQrCode:KLINKSTR QrCodeImageSize:0 RGB:@"#ee68ba"];;
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
- (void)viewDidLayoutSubviews{
    
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
        make.top.mas_equalTo(weakSelf.creatBtn.mas_bottom).offset(10);
        make.width.height.mas_equalTo(ScreenWidth-20);
        
    }];
    

}
#pragma mark-> 二维码扫描
- (void)scan{
    
    Scan_VC*vc=[[Scan_VC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark-> 二维码生成
- (void)create{
  
    NSString*link;
    if(self.textField.text.length==0){
        
        link=KLINKSTR;
        
    }else{
        
        link=self.textField.text;
        
    }
    UIImage *image = nil;
    
    switch (_count) {
        case 0:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0];
            break;
        case 1:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba"];
            break;
        case 2:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 insertImage:[UIImage imageNamed:@"backImage"] radius:16];
            break;
        case 3:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba" insertImage:[UIImage imageNamed:@"backImage"] radius:16];
            break;
        case 4:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 backgroundImage:[UIImage imageNamed:@"backImage"]];
            break;
        case 5:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba" backgroundImage:[UIImage imageNamed:@"backImage"] insertImage:[UIImage imageNamed:@"backImage"] radius:16];
            break;
        case 6:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状111"]];
            break;
        case 7:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状222"] color1:@"#1dacea" color2:@"#2d9f7c"];
            break;
        case 8:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状111"] color1:nil color2:nil backgroundImage:[UIImage imageNamed:@"backImage"]];
            break;
        case 9:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状222"] color1:@"#d40606" color2:@"#a10acc" backgroundImage:[UIImage imageNamed:@"backImage"] insertImage:[UIImage imageNamed:@"backImage"] radius:16];
            break;
    }
    
    _count=(_count==9)?0:(_count+1);
    _outImageView.image=image;
    
}
#pragma mark-> 长按识别二维码
- (void)dealLongPress:(UIGestureRecognizer*)gesture{
    NSLog(@"%ld",gesture.state);
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
                CGImageRelease(imageToDecode);
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
            CGImageRelease(imageToDecode);
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
        
        
    }else if (gesture.state==UIGestureRecognizerStateEnded||UIGestureRecognizerStateCancelled==gesture.state){
        
        _timer.fireDate=[NSDate distantPast];
        
    }
    
  }
}
#pragma mark->textFiel delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    _timer.fireDate=[NSDate distantFuture];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    _timer.fireDate=[NSDate distantPast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
