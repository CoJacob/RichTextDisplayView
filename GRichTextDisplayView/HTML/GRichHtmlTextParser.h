//
//  GRichHtmlTextParser.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/19.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHTMLContentMutableComponents : NSObject

@property (nonatomic, readonly) NSMutableString     *fullString;
@property (nonatomic, readonly) NSMutableDictionary *hrefs; //{Range:Url}
@property (nonatomic, readonly) NSMutableArray      *boldRanges;
@property (nonatomic, readonly) NSMutableArray      *searchRanges;
@property (nonatomic, readonly) NSMutableArray      *imgs;
@property (nonatomic, readonly) NSMutableArray      *contentArray;


@end

typedef NS_ENUM(NSUInteger, GHTMLParserOption){
    GHTMLParserOptionParagraphNone = 1 << 0,
    GHTMLParserOptionParagraph = 1 << 1,
    GHTMLParserOptionComponentHref = 1 << 10,
    GHTMLParserOptionComponentBold = 1 << 11,
    GHTMLParserOptionComponentSearch = 1 << 12,
    GHTMLParserOptionComponentImg = 1 << 13,
    GHTMLParserOptionAll = 0xffff
};


@interface GRichHtmlTextParser : NSObject


/**
 解析一段html文本
 
 @param contentHtml html文本
 @param option 解析选项
 @return 特定格式的内容dict数组
 */
+ (NSArray *) parserHtmlContent:(NSString *)contentHtml
                         option:(GHTMLParserOption)option;

@end
