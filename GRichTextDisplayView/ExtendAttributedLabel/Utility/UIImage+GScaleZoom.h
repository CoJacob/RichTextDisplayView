//
//  UIImage+GScaleZoom.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/17.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GScaleZoom)


/**
 图片等比缩放

 @param image 要缩放的图片
 @param newSize 图片size
 @return 处理后的图片
 */
- (UIImage *)imageWithImage:(UIImage*)image scaledToSize: (CGSize)newSize;


/**
 图片合成(绘制一张背景为纯色中间区域不变形的图)

 @param image 原图
 @param color 颜色
 @param size 生成到图片尺寸
 @return 合成后的图
 */
- (UIImage *)drawRectImageWithBorderColor: (UIColor *)color
                               size: (CGSize )size;

@end
