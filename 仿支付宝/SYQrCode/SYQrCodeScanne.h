//
//  SYQrCodeScanne.h
//  SYQrCodeDemo
//
//  Created by 陈蜜 on 16/5/6.
//  Copyright © 2016年 sunyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SYCodeType) {
    
    /**
     *  未知
     */
    SYCodeTypeUnknow,
    /**
     *  链接
     */
    SYCodeTypeLink,
    /**
     *  字符串
     */
    SYCodeTypeString
};

@interface SYQrCodeScanne : UIViewController

/**
 *  进行扫描
 */
- (void)scanning;


/**
 *  扫描成功回调
 */
@property (nonatomic, copy) void (^scanneScusseBlock)(SYCodeType codeType, NSString *url);



@end
