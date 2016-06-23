//
//  UIImage+SYGenerateQrCode.h
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/9.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SYGenerateQrCode)

/**
 *  生成二维码图片
 *
 *  @param link 二维码链接
 *  @param size 尺寸 传0为默认尺寸
 *
 *  @return 返回生成的图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size;

/**
 *  生成自定义颜色二维码
 *
 *  @param link     链接
 *  @param size     尺寸 传0为默认尺寸
 *  @param rgbValue 色值
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                                 RGB:(NSString *)rgbValue;

/**
 *  二维码添加背景图
 *
 *  @param link            链接
 *  @param size            尺寸 传0为默认尺寸
 *  @param backgroundImage 背景图
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                     backgroundImage:(UIImage *)backgroundImage;

/**
 *  中心插入图片
 *
 *  @param link        链接
 *  @param size        尺寸 传0为默认尺寸
 *  @param insertImage 插入的图片
 *  @param radius      圆角
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius;


/**
 *  中心插入图片并修改二维码颜色
 *
 *  @param link        链接
 *  @param size        尺寸 传0为默认尺寸
 *  @param insertImage 插入的图片
 *  @param radius      圆角
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                                 RGB:(NSString *)rgbValue
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius;


/**
 *  生成自定义颜色并且中心插入图片的二维码图片
 *
 *  @param link        链接
 *  @param size        尺寸 传0为默认尺寸
 *  @param rgbValue    色值
 *  @param insertImage 插入的图片
 *  @param radius      圆角
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                                 RGB:(NSString *)rgbValue
                     backgroundImage:(UIImage *)backgroundImage
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius;


/**
 *  设置二维码填充图片
 *
 *  @param link      二维码链接
 *  @param size      尺寸 传0为默认尺寸
 *  @param fillImage 填充图片
 *
 *  @return  二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage;



/**
 *  设置二维码填充图片，并自定义填充图片颜色
 *
 *  @param link      二维码链接
 *  @param size      尺寸 传0为默认尺寸
 *  @param fillImage 填充图片
 *  @param color1、color2  可修改填充图片的色彩，只适用于黑白两色的简单图片
 *
 *  @return  二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
                              color1:(NSString *)color1
                              color2:(NSString *)color2;


/**
 *  设置二维码填充图片，并自定义填充图片颜色，添加背景图片
 *
 *  @param link      二维码链接
 *  @param size      尺寸 传0为默认尺寸
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
                     backgroundImage:(UIImage *)backgroundImage;

/**
 *  设置二维码填充图片，并自定义填充图片颜色，添加背景图片, 中心插入图片
 *
 *  @param link            链接
 *  @param size            尺寸 传0为默认尺寸
 *  @param fillImage       填充图片
 *  @param color1          颜色1
 *  @param color2          颜色2
 *  @param backgroundImage 背景图
 *  @param insertImage     插入图
 *  @param radius          圆角角度
 *
 *  @return 二维码图片
 */
+ (UIImage *)generateImageWithQrCode:(NSString *)link
                     QrCodeImageSize:(CGFloat)size
                           fillImage:(UIImage *)fillImage
                              color1:(NSString *)color1
                              color2:(NSString *)color2
                     backgroundImage:(UIImage *)backgroundImage
                         insertImage:(UIImage *)insertImage
                              radius:(CGFloat)radius;



@end
