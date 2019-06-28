//
//  GRichTextItem.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/19.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface GRichTextItem : NSObject

@property (nonatomic, strong,readonly) NSMutableAttributedString *attributedString;
@property (nonatomic, strong,readonly) NSDictionary              *hrefDict;
@property (nonatomic, strong,readonly) NSArray                   *italicArray;

/**
 解析文本内容

 @param content htmlContent
 @param fontSize 字号
 @return GRichTextItem对象
 */
- (instancetype)initWithContent: (id )content fontSize: (CGFloat )fontSize;

@end
