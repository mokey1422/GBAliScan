//
//  UIImage+SYQrCodeDiversification.h
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/9.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYColorModel.h"

@interface UIImage (SYQrCodeDiversification)

/**
 *  改变二维码颜色
 *
 *  @param image    二维码图片
 *  @param rgbValue 色值 例如：#ee68ba
 *
 *  @return 返回处理后图片
 */
+ (UIImage *)imageDiversificationWithImage:(UIImage *)image RGB:(NSString *)rgbValue;


/**
 *  图片添加到二维码中心
 *
 *  @param originImage 二维码原图
 *  @param insertImage 插入的图片
 *  @param radius      圆角角度
 *
 *  @return 返回处理后的图片
 */
+ (UIImage *)imageInsertedImage: (UIImage *)originImage
                    insertImage: (UIImage *)insertImage
                         radius: (CGFloat)radius;

/**
 *  二维码添加背景图
 *
 *  @param originImage     原图
 *  @param backgroundImage 背景图
 *
 *  @return 返回处理后的图片
 */
+ (UIImage *)imageSetBackgroundImage:(UIImage *)originImage
                     backgroundImage:(UIImage *)backgroundImage;

/**
 *  填充图片
 */
+ (UIImage *)qrCodeFillImageWithQrCodeImage:(UIImage *)QrCodeImage fillImage:(UIImage *)fillImage;


/**
 *  填充图片颜色替换
 *
 *  @param color1  颜色1
 *  @param color2 颜色2
 *  @param image      图片
 *
 *  @return 修改后的图片
 */
+ (UIImage *)colorRedrawWithColor1:(NSString *)color1
                           color2:(NSString *)color2
                              byImage:(UIImage *)image;


@end
