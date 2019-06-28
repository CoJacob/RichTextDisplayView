//
//  GRichTextDisplayViewLayout.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRichTextDisplayViewLayout : NSObject

/**
 计算通过richAttributedLabel绘制一段html文本后的高度
 
 @param htmlText html文本
 @param width view宽度
 @param font 字体
 @return 总高度
 */
+ (CGFloat )heightForDrawHtmlText: (NSString *)htmlText
                 viewWidth: (CGFloat )width
                      font: (UIFont *)font;


+ (CGFloat )heightForDrawHtmlText: (NSString *)htmlText
                        viewWidth: (CGFloat )width
                             font: (UIFont *)font
                      retractNumberOfLine: (NSInteger )retractLine;


+ (NSInteger )numberOflinesOfStringForString: (NSString *)string
                                    font: (UIFont *)font
                                   width: (CGFloat )width;


@end
