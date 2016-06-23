//
//  UIImage+SYQrCodeDiversification.m
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/9.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import "UIImage+SYQrCodeDiversification.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+SYRoundImage.h"

@implementation UIImage (SYQrCodeDiversification)

+ (UIImage *)imageDiversificationWithImage:(UIImage *)image RGB:(NSString *)rgbValue
{
    if (!image)return nil;
    
    __block SYColorModel *kColorModel;
    [self colorValue:rgbValue rgbBlock:^(SYColorModel *colorModel) {
        kColorModel = colorModel;
    }];
    
    /** 颜色不能太淡 */
    NSUInteger rgb = (kColorModel.red << 16) + (kColorModel.green << 8) + kColorModel.blue;

    //断言色值高于0xfefefe00的色值为白色，避免颜色太过于接近白色
    NSAssert((rgb & 0xffffff00) <= 0xfefefe00, @"The color of QR code is two close to white color than it will diffculty to scan");

    UIImage * result = [self imageFillBlackColorAndTransparent:image colorModel:kColorModel];
    return result;

}

//色值转换
+ (void)colorValue:(NSString *)rgbValue rgbBlock:(void(^)(SYColorModel *colorModel))rgbBlock
{
    SYColorModel *model = [[SYColorModel alloc]init];
    NSMutableString *mutableRBGString = [NSMutableString stringWithString:rgbValue];
    // 转换成标准16进制数
    [mutableRBGString replaceCharactersInRange:[mutableRBGString rangeOfString:@"#" ] withString:@"0x"];
    // 十六进制字符串转成整形。
    long colorLong = strtoul([mutableRBGString cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
    // 通过位与方法获取三色值
    model.red = (colorLong & 0xFF0000 )>>16;
    model.green = (colorLong & 0x00FF00 )>>8;
    model.blue =  colorLong & 0x0000FF;
    
    if (rgbBlock) {
        rgbBlock(model);
    }
}


/**
 *  填充图像1
 *
 *  @param image 图片
 *  @param colorModel   色值模型
 *
 *  @return 返回最终图片
 */
+ (UIImage *)imageFillBlackColorAndTransparent: (UIImage *)image colorModel:(SYColorModel *)colorModel
{
    return [self imageFillBlackColorAndTransparent:image colorModel1:colorModel colorModel2:nil];
    
}


/**
 *  填充图像2
 *
 *  @param image 图片
 *  @param colorModel1   色值模型1
 *  @param colorModel2   色值模型2
 *
 *  @return 返回最终图片
 */
+ (UIImage *)imageFillBlackColorAndTransparent:(UIImage *)image colorModel1:(SYColorModel *)colorModel1 colorModel2:(SYColorModel *)colorModel2
{
    return [self imageFillBlackColorAndTransparent:image colorModel1:colorModel1 colorModel2:colorModel2 isFill:NO];
}

/**
 *  填充图像3
 *
 *  @param image 图片
 *  @param colorModel1   色值模型1
 *  @param colorModel2   色值模型2
 *
 *  @return 返回最终图片
 */
+ (UIImage *)imageFillBlackColorAndTransparent:(UIImage *)image colorModel1:(SYColorModel *)colorModel1 colorModel2:(SYColorModel *)colorModel2 isFill:(BOOL)isFill
{
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t * rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, (CGRect){(CGPointZero), (image.size)}, image.CGImage);
    
    //遍历像素
    int pixelNumber = imageHeight * imageWidth;
    
    [self fillWhiteToTransparentOnPixel:rgbImageBuf pixelNum:pixelNumber colorModel1:colorModel1 colorModel2:colorModel2 isFill:isFill];
    
    //将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    UIImage * resultImage = [UIImage imageWithCGImage: imageRef];
    
    //释放内存
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return resultImage;
    
}

/**
 *  颜色变化
 */
void ProviderReleaseData(void * info, const void * data, size_t size) {
    
    free((void *)data);
}

/**
 *  遍历所有像素，替换颜色
 *
 *  @param rgbImageBuf RBG色彩数据
 *  @param pixelNum    像素点数
 *  @param colorModel1   色值模型1  为前景颜色、形状颜色
 *  @param colorModel2   色值模型2  为背景颜色，识别为白色
 */
+ (void)fillWhiteToTransparentOnPixel: (uint32_t *)rgbImageBuf pixelNum: (int)pixelNum colorModel1:(SYColorModel *)colorModel1 colorModel2:(SYColorModel *)colorModel2 isFill:(BOOL)isFill
{
    uint32_t * pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if (isFill){
            if (!((*pCurPtr & 0xffffff00) < 0xfefefe00)) {
                uint8_t * ptr = (uint8_t *)pCurPtr;
                ptr[0] = 0;
            }
        }else{
            if ((*pCurPtr & 0xffffff00) < 0xfefefe00) {
                uint8_t * ptr = (uint8_t *)pCurPtr;
                if (colorModel1) {
                    ptr[3] = colorModel1.red;
                    ptr[2] = colorModel1.green;
                    ptr[1] = colorModel1.blue;
                }else{
                    ptr[0] = 0;
                }
            } else{
                //将其他像素变成透明色
                uint8_t * ptr = (uint8_t *)pCurPtr;
                if (colorModel2) {
                    ptr[3] = colorModel2.red;
                    ptr[2] = colorModel2.green;
                    ptr[1] = colorModel2.blue;
                }else{
                    ptr[0] = 0;
                }
            }
        }
    }
}

/**
 *  图片添加到二维码中心
 *
 *  @param originImage 二维码原图
 *  @param insertImage 插入的图片
 *  @param radius      圆角角度
 *
 *  @return 返回处理后的图片
 */
+ (UIImage *)imageInsertedImage:(UIImage *)originImage
                    insertImage:(UIImage *)insertImage
                         radius:(CGFloat)radius
{
    if (!insertImage) return originImage;
    
    insertImage = [UIImage generateRoundedCornersWithImage:insertImage size:insertImage.size radius:radius];
    UIImage * whiteBG = [UIImage imageNamed:@"whiteBG"];
    whiteBG = [UIImage generateRoundedCornersWithImage:whiteBG size:whiteBG.size radius:radius];
    const CGFloat whiteSize = 2.f;
    CGSize brinkSize = CGSizeMake(originImage.size.width / 5, originImage.size.height / 5);
    CGFloat brinkX = (originImage.size.width - brinkSize.width) * 0.5;
    CGFloat brinkY = (originImage.size.height - brinkSize.height) * 0.5;
    CGSize imageSize = CGSizeMake(brinkSize.width - 2 * whiteSize, brinkSize.height - 2 * whiteSize);
    CGFloat imageX = brinkX + whiteSize;
    CGFloat imageY = brinkY + whiteSize;
    UIGraphicsBeginImageContext(originImage.size);
    [originImage drawInRect: (CGRect){ 0, 0, (originImage.size) }];
    [whiteBG drawInRect: (CGRect){ brinkX, brinkY, (brinkSize) }];
    [insertImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}



+ (UIImage *)imageSetBackgroundImage:(UIImage *)originImage backgroundImage:(UIImage *)backgroundImage
{
    CGFloat whiteSize = 115.f;
    if (!backgroundImage) {
        backgroundImage = [UIImage imageNamed:@"whiteBG"];
        whiteSize = 0;
    };
    
    CGSize imageSize = CGSizeMake(backgroundImage.size.width - 2 * whiteSize, backgroundImage.size.height - 2 * whiteSize);
    CGFloat imageX = whiteSize;
    CGFloat imageY = whiteSize;
    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect: (CGRect){ 0, 0, (backgroundImage.size) }];
    [originImage drawInRect: (CGRect){ imageX, imageY, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


+ (UIImage *)colorRedrawWithColor1:(NSString *)color1
                            color2:(NSString *)color2
                           byImage:(UIImage *)image
{
    if (!color1 || !color2) return image;
    
    __block SYColorModel *colorModel1 = nil;
    __block SYColorModel *colorModel2 = nil;
    
    [self colorValue:color1 rgbBlock:^(SYColorModel *colorModel) {
        colorModel1 = colorModel;
    }];
    [self colorValue:color2 rgbBlock:^(SYColorModel *colorModel) {
        colorModel2 = colorModel;
    }];
    UIImage *resultImage = [self imageFillBlackColorAndTransparent:image colorModel1:colorModel1 colorModel2:colorModel2];
    return resultImage;
}



/**
 *  填充图片
 */
+ (UIImage *)qrCodeFillImageWithQrCodeImage:(UIImage *)QrCodeImage fillImage:(UIImage *)fillImage
{
    if (!QrCodeImage || (NSNull *)QrCodeImage == [NSNull null]) return nil;
    if (!fillImage || (NSNull *)fillImage == [NSNull null]) return QrCodeImage;
    
    SYColorModel *colorModel2 = [[SYColorModel alloc]init];
    colorModel2.red = 255;
    colorModel2.green = 255;
    colorModel2.blue = 255;
    //二维码黑色部分变成透明
    UIImage *transparentQrImage = [self imageFillBlackColorAndTransparent:QrCodeImage colorModel1:nil colorModel2:colorModel2];
    //图像合成
    UIImage *syntheticImage = [self imageSyntheticWithQrImage:transparentQrImage fillImage:fillImage];
    
    UIImage *result = [self imageFillBlackColorAndTransparent:syntheticImage colorModel1:nil colorModel2:nil isFill:YES];
    
    return result;
}


//图像合成
+ (UIImage *)imageSyntheticWithQrImage:(UIImage *)qrImage fillImage:(UIImage *)fillImage
{
    UIGraphicsBeginImageContext(qrImage.size);
    [fillImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
    [qrImage drawInRect:CGRectMake(0, 0, qrImage.size.width, qrImage.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}



@end
