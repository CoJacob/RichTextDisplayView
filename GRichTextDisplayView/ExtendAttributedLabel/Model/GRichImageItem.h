//
//  GRichImageItem.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/20.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface GRichImageItem : NSObject

@property (nonatomic, readonly)   NSString *src;
@property (nonatomic, readonly)   CGFloat  height;
@property (nonatomic, readonly)   CGFloat  width;


/**
 解析html中的图片

 @param content img标签内容
 @param width 图片宽度
 @return 解析后的object
 */
- (instancetype)initWithContent:(id)content width: (CGFloat )width;

@end
