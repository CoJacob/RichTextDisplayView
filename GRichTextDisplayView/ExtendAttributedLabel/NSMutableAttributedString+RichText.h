//
//  NSMutableAttributedString+RichText.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (RichText)

- (void)rt_setTextColor:(UIColor*)color;
- (void)rt_setTextColor:(UIColor *)color range: (NSRange )range;

- (void)rt_setItalicForRange: (NSRange )range color: (UIColor *)color;

- (void)rt_setFont: (UIFont *)font;
- (void)rt_setFont: (UIFont *)font range: (NSRange )range;

//- (void)rt_setUnderlineStyle:(CTUnderlineStyle)style
//                     modifier:(CTUnderlineStyleModifiers)modifier;
//- (void)rt_setUnderlineStyle:(CTUnderlineStyle)style
//                     modifier:(CTUnderlineStyleModifiers)modifier
//                        range:(NSRange)range;


@end

NS_ASSUME_NONNULL_END
