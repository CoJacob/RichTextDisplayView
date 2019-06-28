//
//  HTMLParser.h
//  MVendorFramework
//
//  Created by hushaohua on 2017/3/7.
//  Copyright © 2017年 Micker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLContentComponets : NSObject

@property (nonatomic, readonly) NSString       *pureString;
@property (nonatomic, readonly) NSDictionary   *hrefs; //{Range:Url}
@property (nonatomic, readonly) NSArray        *boldRanges;
@property (nonatomic, readonly) NSArray        *searchRanges;
@property (nonatomic, readonly) NSMutableArray *imgs;

@end

typedef NS_ENUM(NSUInteger, HTMLParserOption){
    HTMLParserOptionParagraphNone = 1 << 0,
    HTMLParserOptionParagraph = 1 << 1,
    
    HTMLParserOptionComponentHref = 1 << 10,
    HTMLParserOptionComponentBold = 1 << 11,
    HTMLParserOptionComponentSearch = 1 << 12,
    HTMLParserOptionComponentImg = 1 << 13,
    
    HTMLParserOptionAll = 0xffff
};

@interface HTMLParser : NSObject

+ (NSArray *) parserHtmlContent:(NSString *)contentHtml
                         option:(HTMLParserOption)option
      withPLabelWithNotLine: (BOOL )line;

@end
