//
//  NSMutableAttributedString+RichText.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "NSMutableAttributedString+RichText.h"
#import "GRichTextAttributedLabelDefines.h"

@implementation NSMutableAttributedString (RichText)

- (void)rt_setTextColor:(UIColor*)color {
    [self rt_setTextColor:color range:NSMakeRange(0, self.length)];
}

- (void)rt_setTextColor:(UIColor *)color range: (NSRange )range {
    if (color.CGColor) {
        [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];
        [self addAttribute:(NSString *)kCTForegroundColorAttributeName
                     value:(id)color.CGColor
                     range:range];
    }
}

- (void)rt_setItalicForRange: (NSRange )range color: (UIColor *)color {
    if (color.CGColor) { {
            CGAffineTransform glyphTransform = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
            NSValue *value = CGAffineTransformIsIdentity(glyphTransform) ? nil : [NSValue valueWithCGAffineTransform:glyphTransform];
            [self removeAttribute:(NSString *)GTextGlyphTransformAttributeName range:range];
            [self addAttribute:(NSString *)GTextGlyphTransformAttributeName
                         value:(id)value
                         range:range];
        }
    }
}

- (void)rt_setFont: (UIFont *)font {
    [self rt_setFont:font range:NSMakeRange(0, self.length)];
}

- (void)rt_setFont: (UIFont *)font range: (NSRange )range {
    if (font) {
        [self removeAttribute:(NSString *)kCTFontAttributeName range:range];
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
        if (fontRef) {
            [self addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }
}

- (void)rt_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier {
    [self rt_setUnderlineStyle:style
                       modifier:modifier
                          range:NSMakeRange(0, self.length)];
}

- (void)rt_setUnderlineStyle:(CTUnderlineStyle)style
                     modifier:(CTUnderlineStyleModifiers)modifier
                        range:(NSRange)range {
    [self removeAttribute:(NSString *)kCTUnderlineColorAttributeName range:range];
    [self addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                 value:[NSNumber numberWithInt:(style|modifier)]
                 range:range];
    
}

@end
