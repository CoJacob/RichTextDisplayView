//
//  UIImageView+HRoundCorner.m
//  MNewsFramework
//
//  Created by hushaohua on 12/5/16.
//  Copyright © 2016 Micker. All rights reserved.
//

#import "UIImageView+QNWeb.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"


@implementation UIImageView (QNWeb)
@dynamic targetImageWidth, targetImageHeight, disableImageLoadAniation,disableLayerBorder, currentImageURL;

- (void) setTargetImageWidth:(int)targetImageWidth {
    objc_setAssociatedObject(self, @selector(targetImageWidth), [NSNumber numberWithInt:targetImageWidth], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) setTargetImageHeight:(int)targetImageHeight {
    objc_setAssociatedObject(self, @selector(targetImageHeight), [NSNumber numberWithInt:targetImageHeight], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) setDisableImageLoadAniation:(BOOL)disableImageLoadAniation{
    objc_setAssociatedObject(self, @selector(disableImageLoadAniation), [NSNumber numberWithBool:disableImageLoadAniation], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void) setDisableLayerBorder:(BOOL)disableLayerBorder {
    objc_setAssociatedObject(self, @selector(disableLayerBorder), [NSNumber numberWithBool:disableLayerBorder], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setCurrentImageURL:(NSURL *)currentImageURL {
    objc_setAssociatedObject(self, @selector(currentImageURL), currentImageURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (int) targetImageWidth {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return  [number intValue];
}

- (int) targetImageHeight {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return  [number intValue];
}

- (BOOL) disableImageLoadAniation {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return [number boolValue];
}

- (BOOL) disableLayerBorder {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return [number boolValue];
}

- (NSURL *) currentImageURL {
    NSURL *URL = objc_getAssociatedObject(self, _cmd);
    return URL;
}


- (NSString *)qn_clipMethodWithHeight:(int)height withWidth:(int)width{
    if (height > 0 && width > 0) {
        return [NSString stringWithFormat:@"?imageView2/1/h/%ld/w/%ld/q/100", (long)height, (long)width];
    } else if (height > 0) {
        return [NSString stringWithFormat:@"?imageView2/2/h/%ld/q/100", (long)height];
    } else if (width > 0) {
        return [NSString stringWithFormat:@"?imageView2/2/w/%ld/q/100",  (long)width];
    }
    else {
        return @"";
    }
}

- (NSURL *) clipedImageURLFrom:(NSString *)url{
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* URL = [NSURL URLWithString:url];
    if (URL.query.length == 0){
        float scale = [UIScreen mainScreen].scale;
        NSString *clipString = @"";
        if (0 == self.targetImageWidth && 0 == self.targetImageHeight) {
            clipString = [self qn_clipMethodWithHeight:self.bounds.size.height * scale withWidth:self.bounds.size.width * scale];
        } else {
            clipString = [self qn_clipMethodWithHeight:self.targetImageHeight * scale withWidth:self.targetImageWidth * scale];
        }
        
        NSString* clipedUrl = [url stringByAppendingString:clipString];
        return [NSURL URLWithString:clipedUrl];
    }else{
        return URL;
    }
}

- (void) qn_setClipSizedImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholderImage {
    if (!self.disableLayerBorder) {
        self.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.13].CGColor;
        self.layer.borderWidth = 0.5f;
    }
    if (url == nil || !url.length) {
        self.image = placeholderImage?:nil;
        return;
    }
    __weak __typeof__(self) weakSelf = self;
    if (![[self.currentImageURL absoluteString] isEqualToString:url]) {
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.currentImageURL = [self clipedImageURLFrom:url];
        [self sd_setImageWithURL:self.currentImageURL
                placeholderImage:placeholderImage
                         options:SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageLowPriority | SDWebImageAllowInvalidSSLCertificates
                        progress:NULL
                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                           if (imageURL != weakSelf.currentImageURL) {
//                               return ;
//                           }
                           if (image && !error) {
                               [weakSelf loadImageWithAnimation];
                           }
                       }];
    }
}

//- (NSData *)imageDataFromDiskCacheWithKey:(NSString *)key {
//    
//    NSString *path = [[[SDWebImageManager sharedManager] imageCache] defaultCachePathForKey:key];
//    return [NSData dataWithContentsOfFile:path];
//}

- (void) qn_setClipSizedImageWithUrl:(NSString *)url
                         placeholder:(UIImage *)placeholderImage
                           completed:(void(^)(UIImage* image))completed {
    if (![[self.currentImageURL absoluteString] isEqualToString:url]) {
        self.currentImageURL = [self clipedImageURLFrom:url];
        
//        [self sd_setImageWithPreviousCachedImageWithURL:self.currentImageURL
//                                       placeholderImage:placeholderImage
//                                                options:SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageLowPriority
//                                               progress:nil
//                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//         {
//             if (completed){
//                 completed(image);
//             }
//             [self loadImageWithAnimation];
//         }];
    }
}

- (void) loadImageWithAnimation {
    if (!self.disableImageLoadAniation) {
        self.alpha = 0.5;
        [UIView transitionWithView:self
                          duration:.35
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.alpha = 1.0;
                        }
                        completion:nil];
    }
}

- (NSString *)methodWithHeight:(int)height withWidth:(int)width blur:(CGPoint)blur{
    long xBlur = (long)blur.x;
    long yBlur = (long)blur.y;
    xBlur = xBlur < 1 ? 1 : (xBlur > 50 ? 50 : xBlur);
    yBlur = yBlur < 1 ? 1 : (yBlur > 50 ? 50 : yBlur);
    return [NSString stringWithFormat:@"?imageMogr2/thumbnail/%ldx%ld/blur/%ldx%ld", (long)width, (long)height, xBlur, yBlur];
}

- (NSURL *) clipedImageURLFrom:(NSString *)url blur:(CGPoint)blur{
    NSURL* URL = [NSURL URLWithString:url];
    if (URL.query.length == 0){
        NSInteger scale = [UIScreen mainScreen].scale;
        NSString* clipedUrl = [url stringByAppendingString:[self methodWithHeight:self.bounds.size.height * scale withWidth:self.bounds.size.width * scale blur:blur]];
        return [NSURL URLWithString:clipedUrl];
    }else{
        return URL;
    }
}

- (void) qn_setClipSizedImageWithUrl:(NSString *)url
                         placeholder:(UIImage *)placeholderImage
                                blur:(CGPoint)blur
                           completed:(void(^)(UIImage* image))completed{
    if (![[self.currentImageURL absoluteString] isEqualToString:url]) {
        self.currentImageURL = [self clipedImageURLFrom:url blur:blur];
//        [self sd_setImageWithPreviousCachedImageWithURL:self.currentImageURL
//                                       placeholderImage:placeholderImage
//                                                options:SDWebImageRetryFailed | SDWebImageContinueInBackground | SDWebImageLowPriority
//                                               progress:nil
//                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
//         {
//             if (completed){
//                 completed(image);
//             }
//         }];
    }
}

+ (NSString *)hybridClipMethodWithURLString:(NSString *)URLString {
    if ([URLString containsString:@"wallstcn.com"] ||
        [URLString containsString:@"wallstreetcn.com"]) {
        NSArray *imageURLStringArray = [URLString componentsSeparatedByString:@"?"];
        NSString *originalImageURLString = imageURLStringArray.firstObject;
        return [[self class] appendClippingRuleForURLString:originalImageURLString];
        
    }
    return URLString;
}

+ (NSString *)appendClippingRuleForURLString:(NSString *)URLString {
    NSString *lowerURLString = [URLString lowercaseString];
    NSString *clippingRule = @"?imageMogr2/thumbnail/640/format/jpg";
    if ([lowerURLString containsString:@".gif"]) {
        clippingRule = @"?imageMogr2/thumbnail/640";
    }
    NSString *appendClippingRuleURLString = [NSString stringWithFormat:@"%@%@/size-limit/16k!",URLString, clippingRule];
    return appendClippingRuleURLString;
}

@end
