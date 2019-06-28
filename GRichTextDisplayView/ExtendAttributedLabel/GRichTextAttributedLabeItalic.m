//
//  GRichTextAttributedLabeItalic.m
//  HPayablePostFramework
//
//  Created by Caoguo on 2018/5/17.
//  Copyright © 2018年 wallstreetcn. All rights reserved.
//

#import "GRichTextAttributedLabeItalic.h"

@implementation GRichTextAttributedLabeItalic

+ (GRichTextAttributedLabeItalic *)italicWithRange:(NSRange)range
                                             color:(nullable UIColor *)color {
    GRichTextAttributedLabeItalic *italic  = [[GRichTextAttributedLabeItalic alloc]init];
    italic.range                   = range;
    italic.color                   = color;
    return italic;
}

@end


