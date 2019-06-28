//
//  GRichTextAttributedTextLayout.m
//  GPayFramework
//
//  Created by Caoguo on 2018/9/21.
//  Copyright © 2018年 wallstreetcn. All rights reserved.
//

#import "GRichTextAttributedTextLayout.h"
#import "NSMutableAttributedString+RichText.h"
#import "GRichTextAttributedLabelAttachment.h"

@implementation GRichTextAttributedTextLayout

+ (GRichTextAttributedTextLayout *)layoutWithContainer:(GRichTextAttributedTextContainer *)container text:(NSString *)text {
    GRichTextAttributedTextLayout *layout = [[GRichTextAttributedTextLayout alloc] init];
    if (!text.length) {
        layout.size = CGSizeZero;
    }else {
        layout.size = [self sizeThatFits:CGSizeMake(container.width, CGFLOAT_MAX)
                               container:container
                                    text:text];
    }
    
    return layout;
}

+ (GRichTextAttributedTextLayout *)layoutWithContainer:(GRichTextAttributedTextContainer *)container attributedText:(NSAttributedString *)attributedText {
    GRichTextAttributedTextLayout *layout = [[GRichTextAttributedTextLayout alloc] init];
    layout.size = CGSizeMake(container.width, 0);
    if (attributedText.length) {
        GRichTextAttributedLabel *attributedLabel = [[GRichTextAttributedLabel alloc] initWithFrame:CGRectZero];
        attributedLabel.numberOfLines = container.numberOfLines;
        attributedLabel.textAlignment = container.textAlignment;
        attributedLabel.lineSpacing = container.lineSpacing;
        attributedLabel.attributedText = nil;
        if (container.attachments.count) {
            [attributedLabel appendImage:container.attachments[0]];
        }
        [attributedLabel appendAttributedText:attributedText];
        CGSize labelSize       = [attributedLabel sizeThatFits:CGSizeMake(container.width, CGFLOAT_MAX)];
        layout.size = labelSize;
    }
    return layout;
}

+ (NSAttributedString *)attributedString:(NSString *)text
                                    font: (UIFont *)font
                               textColor: (UIColor *)textColor {
    if ([text length]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
        [string rt_setFont:font];
        [string rt_setTextColor:textColor];
        return string;
    }else {
        return [[NSAttributedString alloc] init];
    }
}

+ (NSAttributedString *)attributedStringForDraw: (GRichTextAttributedTextContainer *)container text: (NSString *)text {
    NSAttributedString *_attributedString = [self attributedString:text
                                                              font:container.font
                                                         textColor:container.textColor];
    if (_attributedString) {
        //添加排版格式
        NSMutableAttributedString *drawString = [_attributedString mutableCopy];
        
        //如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
        CTLineBreakMode lineBreakMode = container.lineBreakMode;
        if (lineBreakMode == kCTLineBreakByTruncatingTail) {
            lineBreakMode = container.numberOfLines == 1 ? kCTLineBreakByTruncatingTail : kCTLineBreakByWordWrapping;
        }
        CGFloat fontLineHeight = container.font.lineHeight;  //使用全局fontHeight作为最小lineHeight
        
        CTTextAlignment textAlignment = container.textAlignment;
        CGFloat lineSpacing = container.lineSpacing;
        CGFloat paragraphSpacing = container.paragraphSpacing;
   
        CTParagraphStyleSetting settings[] =
        {
            {kCTParagraphStyleSpecifierAlignment,sizeof(container.textAlignment),&(textAlignment)},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(container.lineSpacing),&lineSpacing},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(container.lineSpacing),&lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(container.paragraphSpacing),&paragraphSpacing},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(fontLineHeight),&fontLineHeight},
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
        [drawString addAttribute:(id)kCTParagraphStyleAttributeName
                           value:(__bridge id)paragraphStyle
                           range:NSMakeRange(0, [drawString length])];
        CFRelease(paragraphStyle);
        return drawString;
    }else {
        return nil;
    }
}

+ (CGSize)sizeThatFits:(CGSize)size
             container: (GRichTextAttributedTextContainer *)container
                  text:(NSString *)text {
    NSMutableAttributedString *drawString = [[NSMutableAttributedString alloc] init];
    if (container.attachments.count) {
        return [self sizeForContainer:container text:text];
    }
    [drawString appendAttributedString:[self attributedStringForDraw:container text:text]];
    if (!drawString) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (container.numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(container.numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    
    CGFloat _fontHeight = 0 ;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)container.font.fontName, container.font.pointSize, NULL);
    if (fontRef) {
        _fontHeight     = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
    
    //hack:
    //1.需要加上额外的一部分size,有些情况下计算出来的像素点并不是那么精准
    //2.iOS7 的 CTFramesetterSuggestFrameSizeWithConstraint 方法比较残,需要多加一部分 height
    //3.iOS7 多行中如果首行带有很多空格，会导致返回的 suggestionWidth 远小于真实 width ,那么多行情况下就是用传入的 width
    if (newSize.height < _fontHeight * 2) { //单行
        return CGSizeMake(ceilf(newSize.width) + 2.0, ceilf(newSize.height) + 4.0);
    }
    else {
        return CGSizeMake(size.width, ceilf(newSize.height) + 4.0);
    }
}

+ (CGSize )sizeForContainer: (GRichTextAttributedTextContainer *)container text:(NSString *)text {
    GRichTextAttributedLabel *attributedLabel = [[GRichTextAttributedLabel alloc] initWithFrame:CGRectZero];
    attributedLabel.font = container.font;
    attributedLabel.numberOfLines = container.numberOfLines;
    attributedLabel.textAlignment = container.textAlignment;
    attributedLabel.lineSpacing = container.lineSpacing;
    NSAttributedString *attributedText = [GRichTextAttributedTextLayout attributedStringForDraw:container text:text];
    attributedLabel.attributedText = nil;
    if (container.attachments.count) {
        [attributedLabel appendImage:container.attachments[0]];
    }
    [attributedLabel appendAttributedText:attributedText];
    CGSize labelSize       = [attributedLabel sizeThatFits:CGSizeMake(container.width, CGFLOAT_MAX)];
    return labelSize;
}


@end


@implementation GRichTextAttributedTextContainer: NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.attachments = [NSMutableArray array];
    }
    return self;
}

- (void)appendImage:(UIImage *)image {
//    GRichTextAttributedLabelAttachment *attachment = [GRichTextAttributedLabelAttachment attachmentWith:image
//                                                                                                 margin:UIEdgeInsetsZero
//                                                                                              alignment:RichTextImageAlignmentBottom
//                                                                                                maxSize:image.size];
//    [self appendAttachment:attachment];
//    NSTextAttachment *attachment = [[NSTextAttachment alloc]init];
//    attachment.image = image;
//    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
//
//    NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attachment];
    if (image) {
        [self.attachments addObject:image];
    }
}



@end
