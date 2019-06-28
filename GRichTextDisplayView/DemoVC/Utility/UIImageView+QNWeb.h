//
//  UIImageView+HRoundCorner.h
//  MNewsFramework
//
//  Created by hushaohua on 12/5/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (QNWeb)


/**
 是否开启动画, 默认开启, 如果需要关闭, 需要置为YES
 */
@property (nonatomic, assign) BOOL disableImageLoadAniation;

/**
 是否开启切角, 默认开启, 如果需要关闭, 需要置为YES
 */
@property (nonatomic, assign) BOOL disableLayerBorder;

/**
 需要获取到目标图片的宽度，如果宽高均不设，则使用当前视图的大小
 */
@property (nonatomic, assign) int targetImageWidth;

/**
 需要获取到目标图片的高度，如果宽高均不设，则使用当前视图的大小
 */
@property (nonatomic, assign) int targetImageHeight;


/**
 保存当前加载的图片URL, 如果URL有更改, 则再次使用SDWebImage加载图片
 */
@property (nonatomic, strong) NSURL *currentImageURL;

- (void) qn_setClipSizedImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholderImage;

- (void) qn_setClipSizedImageWithUrl:(NSString *)url
                         placeholder:(UIImage *)placeholderImage
                           completed:(void(^)(UIImage* image))completed;

//Blur x,y max:50,min:1
- (void) qn_setClipSizedImageWithUrl:(NSString *)url
                         placeholder:(UIImage *)placeholderImage
                                blur:(CGPoint)blur
                           completed:(void(^)(UIImage* image))completed;


+ (NSString *)hybridClipMethodWithURLString:(NSString *)URLString;

+ (NSString *)appendClippingRuleForURLString:(NSString *)URLString;

@end
