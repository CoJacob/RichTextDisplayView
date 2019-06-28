//
//  GRichTextDisplayViewLayout.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichTextDisplayViewLayout.h"
#import "GRichTextAttributedLabel.h"
#import "GRichTextItem.h"
#import "GRichImageItem.h"
#import "GRichTextDisplayView.h"
#import "GRichHtmlTextParser.h"
#import "UIImage+GScaleZoom.h"

@implementation GRichTextDisplayViewLayout

+ (CGFloat )heightForDrawHtmlText: (NSString *)htmlText
                        viewWidth: (CGFloat )width
                             font: (UIFont *)font {
    if (htmlText.length == 0) {
        return 0;
    }
    GRichTextDisplayView *richTextView = [[GRichTextDisplayView alloc] initWithFrame:CGRectMake(15, 15, width, 0.1)];
    richTextView.richTextFont   = font;
    CGFloat textHeight = 0;
    [richTextView displayContentWithHtmlText:htmlText];
    textHeight = [richTextView contentHeight];
    return textHeight;
}

+ (CGFloat )heightForDrawHtmlText: (NSString *)htmlText
                        viewWidth: (CGFloat )width
                             font: (UIFont *)font
              retractNumberOfLine: (NSInteger )retractLine {
    if (retractLine == 0) {
        return [self heightForDrawHtmlText:htmlText
                                 viewWidth:width
                                      font:font];
    }else {
        NSArray *componenets = [GRichHtmlTextParser parserHtmlContent:htmlText option:(GHTMLParserOptionParagraph |GHTMLParserOptionComponentBold | GHTMLParserOptionComponentHref |
                                                                                       GHTMLParserOptionComponentImg | GHTMLParserOptionComponentSearch)];
        GHTMLContentMutableComponents *component = componenets.firstObject;
        if (component.fullString.length == 0 && ![self containImgDict:component]) {
            return 0;
        }else {
            NSInteger lineCount = [self numberOflinesOfStringForString:component.fullString
                                                                  font:font
                                                                 width:width];
            if (lineCount <= retractLine) {
                return [self heightForDrawHtmlText:htmlText
                                         viewWidth:width
                                              font:font];
            }else {
                CGFloat textHeight = [self heightForAttributedLabelWithComponets:component
                                                                       viewWidth:width
                                                                            font:font
                                                             retractNumberOfLine:retractLine];
                return textHeight;
            }
        }
    }
}

+ (BOOL )containImgDict: (GHTMLContentMutableComponents *)component {
    __block BOOL _containImg = NO;
    [component.contentArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj allKeys] containsObject:@"img"]) {
            _containImg = YES;
            *stop = YES;
        }
    }];
    return _containImg;
}

+ (CGFloat )heightForAttributedLabelWithComponets: (GHTMLContentMutableComponents *)component
                                       viewWidth: (CGFloat )width
                                            font: (UIFont *)font
                              retractNumberOfLine: (NSInteger )retractLine {
    GRichTextAttributedLabel *attributedLabel = [[GRichTextAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, width, 0.1f)];
    attributedLabel.lineSpacing               = 8.f;
    attributedLabel.numberOfLines             = retractLine;    
    if (component.contentArray.count > 0) {
        [component.contentArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj allKeys] containsObject:@"string"]) {
                [[self class] appendTextWithTextElement:obj
                                        attributedLabel:attributedLabel
                                               fontSize:font.pointSize];
            }else if ([[obj allKeys] containsObject:@"img"] && (retractLine == 0)) {
                [[self class] appendImgeContentWithElement:obj
                                           attributedLabel:attributedLabel
                                                     width:width];
            }
        }];
    }else {
        NSAttributedString *attributedString = [[self class] defaultArrtibutedStringWithText:component.fullString fontSize:font.pointSize];
        [attributedLabel appendAttributedText:attributedString];
    }
    CGSize labelSize = [attributedLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    return labelSize.height;
}


+ (void)appendImgeContentWithElement: (NSDictionary *)imgDict
                     attributedLabel: (GRichTextAttributedLabel *)label
                               width: (CGFloat )width {
    GRichImageItem *imageItem = [[GRichImageItem alloc] initWithContent:imgDict width:width];
    UIImage *placeHolderImage = [UIImage imageNamed:@"xuangubao_w"];
    UIImage *attachementImage = [placeHolderImage drawRectImageWithBorderColor:[UIColor whiteColor] size:CGSizeMake(imageItem.width, imageItem.height)];
    [label appendImage:attachementImage maxSize:CGSizeMake(width, imageItem.height)];
}

+ (void)appendTextWithTextElement: (NSDictionary *)textDict
                  attributedLabel: (GRichTextAttributedLabel *)label
                         fontSize: (NSInteger )fontSize {
    GRichTextItem *textItem = [[GRichTextItem alloc] initWithContent:textDict
                                                            fontSize:fontSize];
    if ([textItem.attributedString string].length == 0) {
        return;
    }
    [label appendAttributedText:textItem.attributedString];
}

+ (NSMutableAttributedString *)defaultArrtibutedStringWithText: (NSString *)text
                                                      fontSize: (NSInteger )fontSize {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                                                                                          NSForegroundColorAttributeName:[UIColor colorWithRed:(51/255.f) green:(51/255.f) blue:(51/255.f) alpha:1]
                                                                                                          }]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing              = 8;
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

+ (NSInteger )numberOflinesOfStringForString: (NSString *)string
                                        font: (UIFont *)font
                                       width: (CGFloat )width {
    return [self linesForString:string
                           font:font
                          width:width].count;
}

+ (NSArray *)linesForString: (NSString *)string
                       font: (UIFont *)font
                      width: (CGFloat )width {
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,width,100000));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    
    CFRelease(myFont);
    CFRelease(frameSetter);
    CFRelease(frame);
    CGPathRelease(path);
    return lines;
}


@end
