//
//  UIImage+GScaleZoom.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/17.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "UIImage+GScaleZoom.h"

@implementation UIImage (GScaleZoom)

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize: (CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)drawRectImageWithBorderColor: (UIColor *)color
                                     size: (CGSize )size {
    UIImage *backgroundImage = [self imageWithColor:color size:size];
    UIGraphicsBeginImageContext(backgroundImage.size);
     // 绘制第一张图片的起始点
    [backgroundImage drawAtPoint:CGPointMake(0, 0)];
     // 绘制第二张图片的起始点
    [self drawAtPoint:CGPointMake(backgroundImage.size.width/2-20, backgroundImage.size.height/2-20)];
    //  获取已经绘制好的
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //  结束绘制
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageWithColor:(UIColor *)color  size: (CGSize )size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);//在这段上下文中获取到颜色UIColor
    CGContextFillRect(context, rect);//用这个颜色填充这个上下文
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();//从这段上下文中获取Image属性,,,结束
    UIGraphicsEndImageContext();
    
    return image;
}

@end
