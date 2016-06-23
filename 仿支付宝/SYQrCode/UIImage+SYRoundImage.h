//
//  UIImage+SYRoundImage.h
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/9.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SYRoundImage)

/**
 *  生成圆角图片
 *
 *  @param image  图片
 *  @param size   尺寸
 *  @param radius 角度
 *
 *  @return 图片
 */
+ (UIImage *)generateRoundedCornersWithImage:(UIImage *)image size:(CGSize)size radius:(CGFloat)radius;

@end
