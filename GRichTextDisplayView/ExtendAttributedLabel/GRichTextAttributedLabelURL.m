//
//  GRichTextAttributedLabelURL.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichTextAttributedLabelURL.h"
#import "GRichTextAttributedLabelDefines.h"

static NSString *RichTextURLExpression = @"((([A-Za-z]{3,9}:(?:\\/\\/)?)(?:[\\-;:&=\\+\\$,\\w]+@)?[A-Za-z0-9\\.\\-]+|(?:www\\.|[\\-;:&=\\+\\$,\\w]+@)[A-Za-z0-9\\.\\-]+)((:[0-9]+)?)((?:\\/[\\+~%\\/\\.\\w\\-]*)?\\??(?:[\\-\\+=&;%@\\.\\w]*)#?(?:[\\.\\!\\/\\\\\\w]*))?)";

static RichTextCustomDetectLinkBlock customDetectBlock = nil;

static NSString *RichTextURLExpressionKey = @"RichTextURLExpressionKey";

@implementation GRichTextAttributedLabelURL

+ (GRichTextAttributedLabelURL *)urlWithLinkData:(id)linkData
                                           range:(NSRange)range
                                           color:(nullable UIColor *)color {
    GRichTextAttributedLabelURL *url  = [[GRichTextAttributedLabelURL alloc]init];
    url.linkData                = linkData;
    url.range                   = range;
    url.color                   = color;
    return url;
}

+ (nullable NSArray *)detectLinks:(nullable NSString *)plainText {
    if (customDetectBlock) {
        return customDetectBlock(plainText);
    } else {
        NSMutableArray *links = nil;
        if ([plainText length]) {
            links = [NSMutableArray array];
            NSRegularExpression *urlRegex = [GRichTextAttributedLabelURL urlExpression];
            [urlRegex enumerateMatchesInString:plainText
                                       options:0
                                         range:NSMakeRange(0, [plainText length])
                                    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                        NSRange range = result.range;
                                        NSString *text = [plainText substringWithRange:range];
                                        GRichTextAttributedLabelURL *link = [GRichTextAttributedLabelURL urlWithLinkData:text
                                                                                                       range:range
                                                                                                       color:nil];
                                        [links addObject:link];
                                    }];
        }
        return links;
    }
}

+ (NSRegularExpression *)urlExpression {
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSRegularExpression *exp = dict[RichTextURLExpressionKey];
    if (!exp) {
        exp = [NSRegularExpression regularExpressionWithPattern:RichTextURLExpression
                                                        options:NSRegularExpressionCaseInsensitive
                                                          error:nil];
        dict[RichTextURLExpressionKey] = exp;
    }
    return exp;
}

+ (void)setCustomDetectMethod:(nullable RichTextCustomDetectLinkBlock)block {
    customDetectBlock = [block copy];
}

@end
