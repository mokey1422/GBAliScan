//
//  UIImage+SYGenerateQrCode.m
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/9.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import "UIImage+SYGenerateQrCode.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+SYQrCodeDiversification.h"

#define SYNormalRGB @"#000000"

@implementation UIImage (SYGenerateQrCode)

+ (UIImage *)generateImageWithQrCode:(NSString *)link QrCodeImageSize:(CGFloat)size
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size RGB:SYNormalRGB backgroundImage:nil insertImage:nil radius:0];;
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link QrCodeImageSize:(CGFloat)size RGB:(NSString *)rgbValue
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size RGB:rgbValue backgroundImage:nil insertImage:nil radius:0];
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link QrCodeImageSize:(CGFloat)size backgroundImage:(UIImage *)backgroundImage
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size RGB:SYNormalRGB backgroundImage:backgroundImage insertImage:nil radius:0];
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size RGB:SYNormalRGB backgroundImage:nil insertImage:insertImage radius:radius];
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                                 RGB:(NSString *)rgbValue
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size RGB:rgbValue backgroundImage:nil insertImage:insertImage radius:radius];
}


+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                                 RGB:(NSString *)rgbValue
                     backgroundImage:(UIImage *)backgroundImage
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius
{
    if (!link || (NSNull *)link == [NSNull null]) return nil;
    
    CGFloat codeSize = [self checkQrCodeImageSize:size];
    CIImage *image = [self drawQrCodeImageWithLink:link];
    UIImage *originImage = [self adjustClarityImageFromCIImage:image size:1024];
    UIImage *rgbImage = [self imageDiversificationWithImage:originImage RGB:rgbValue];
    UIImage *insert = [self imageInsertedImage:rgbImage insertImage:insertImage radius:radius];
    UIImage *result = [self imageSetBackgroundImage:insert backgroundImage:backgroundImage];
    return [self resetImageSize:codeSize byImage:result];
}

/**
 *  设置二维码填充图片
 *
 *  @param link      二维码链接
 *  @param size      尺寸
 *  @param fillImage 填充图片
 *
 *  @return  二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size fillImage:fillImage color1:nil color2:nil];
}

/**
 *  设置二维码填充图片
 *
 *  @param link      二维码链接
 *  @param size      尺寸
 *  @param fillImage 填充图片
 *  @param color1、color2  可修改填充图片的色彩，只适用于黑白两色的简单图片
 *
 *  @return  二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
                              color1:(NSString *)color1
                              color2:(NSString *)color2
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size fillImage:fillImage color1:color1 color2:color2 backgroundImage:nil];
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
                              color1:(NSString *)color1
                              color2:(NSString *)color2
                     backgroundImage:(UIImage *)backgroundImage
{
    return [self generateImageWithQrCode:link QrCodeImageSize:size fillImage:fillImage color1:color1 color2:color2 backgroundImage:backgroundImage insertImage:nil radius:0];
}

+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
                              color1:(NSString *)color1
                              color2:(NSString *)color2
                     backgroundImage:(UIImage *)backgroundImage
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius
{
    if (!link || (NSNull *)link == [NSNull null]) return nil;
    
    CGFloat codeSize = [self checkQrCodeImageSize:size];
    CIImage *image = [self drawQrCodeImageWithLink:link];
    UIImage *originImage = [self adjustClarityImageFromCIImage:image size:1024];
    UIImage *reFillImage = [self colorRedrawWithColor1:color1 color2:color2 byImage:fillImage];
    UIImage *reQrCodeImage = [self qrCodeFillImageWithQrCodeImage:originImage fillImage:reFillImage];
    UIImage *insert = [self imageInsertedImage:reQrCodeImage insertImage:insertImage radius:radius];
    UIImage *result = [self imageSetBackgroundImage:insert backgroundImage:backgroundImage];
    return [self resetImageSize:codeSize byImage:result];;
}

/**
 *  检查二维码尺寸是否符合规定
 *
 *  @param size 尺寸
 */
+ (CGFloat)checkQrCodeImageSize:(CGFloat)size
{
    size = (size==0)?1024:size;
    size = MAX(200, size);
    return size;
}


/**
 *  绘制二维码图片
 *
 *  @param link 二维码链接
 */
+ (CIImage *)drawQrCodeImageWithLink: (NSString *)link
{
    NSData * data = [link dataUsingEncoding: NSUTF8StringEncoding];
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    return filter.outputImage;
}

/**
 *  调整清晰度，使其更加清晰
 *
 *  @param image 图片
 *  @param size  图片尺寸
 */
+ (UIImage *)adjustClarityImageFromCIImage: (CIImage *)image size: (CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef,(CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    
    UIImage*tempIMage=[UIImage imageWithCGImage:imageRefResized];
    
    //释放
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRefResized);
    return tempIMage;
    
}


/**
 *  重置图片尺寸
 */
+ (UIImage *)resetImageSize:(CGFloat)size byImage:(UIImage *)image
{
    if (!image) return nil;
    if (size == 1024) return image;
    
    CGSize imageSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContext(imageSize);
    [image drawInRect: (CGRect){ 0, 0, (imageSize) }];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}


@end
