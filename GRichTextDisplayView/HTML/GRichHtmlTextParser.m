//
//  GRichHtmlTextParser.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/19.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichHtmlTextParser.h"
#import "TFHpple.h"

@interface GHTMLContentMutableComponents ()

@property (nonatomic, strong) NSMutableString     *tempString;
@property (nonatomic, strong) NSMutableDictionary *hrefs; //{Range:Url}
@property (nonatomic, strong) NSMutableArray      *boldRanges;
@property (nonatomic, strong) NSMutableArray      *searchRanges;
@property (nonatomic, strong) NSMutableArray      *imageIndexs;
@property (nonatomic, strong) NSMutableArray      *imgs;
@property (nonatomic, strong) NSMutableArray      *contentArray;
@property (nonatomic, strong) NSMutableString     *fullString;
@property (nonatomic, assign) NSInteger           imageDictCount;

@end

@implementation GHTMLContentMutableComponents

- (id) initWithOption:(GHTMLParserOption)option {
    self = [super init];
    if (self){
        self.imageDictCount = 0;
        self.tempString     = [NSMutableString string];
        self.fullString     = [NSMutableString string];
        if (option & GHTMLParserOptionComponentHref){
            self.hrefs = [NSMutableDictionary dictionary];
        }
        if (option & GHTMLParserOptionComponentBold){
            self.boldRanges = [NSMutableArray array];
        }
        if (option & GHTMLParserOptionComponentSearch){
            self.searchRanges = [NSMutableArray array];
        }
        if (option & GHTMLParserOptionComponentImg) {
            self.imgs = [NSMutableArray array];
        }
        self.contentArray = [NSMutableArray array];
    }
    return self;
}

@end



@implementation GRichHtmlTextParser

+ (NSString *) escapedUrlEncodedStringFrom:(NSString *)string {
    NSMutableString* text = [[NSMutableString alloc] initWithString:string];
    [text replaceOccurrencesOfString:@"&nbsp;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&mdash;" withString:@"--" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&ldquo;" withString:@"“" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&rdquo;" withString:@"”" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    return text;
}

+ (NSArray *) parserHtmlContent:(NSString *)contentHtml
                         option:(GHTMLParserOption)option {
    if (!contentHtml || contentHtml.length == 0) {
        return [NSMutableArray array];
    }
    GHTMLContentMutableComponents* normalComponents = nil;
    GHTMLContentMutableComponents* paragraphComponents = nil;
    if (option & GHTMLParserOptionParagraphNone){
        normalComponents = [[GHTMLContentMutableComponents alloc] initWithOption:option];
    }
    if (option & GHTMLParserOptionParagraph){
        paragraphComponents = [[GHTMLContentMutableComponents alloc] initWithOption:option];
    }
    NSString* escapedUrlEncodedContent = [[self escapedUrlEncodedStringFrom:contentHtml] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData* data = [escapedUrlEncodedContent dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple* hpple = [TFHpple hppleWithHTMLData:data];
    NSArray* elements = [hpple searchWithXPathQuery:@"/"];
    for (NSInteger idx = 0; idx < elements.count; ++idx) {
        TFHppleElement* element = elements[idx];
        if (normalComponents){
            [self parseElement:element
                  toComponents:normalComponents
                     paragraph:NO];
        }
        if (paragraphComponents){
            [self parseElement:element
                  toComponents:paragraphComponents
                     paragraph:YES];
        }
    }
    if (paragraphComponents.fullString.length == 0) {
        return [NSMutableArray array];
    }
    
    if ([[paragraphComponents.fullString substringWithRange:NSMakeRange(paragraphComponents.fullString.length - 1, 1)] isEqualToString:@"\n"]) {
        paragraphComponents.fullString = [[NSMutableString alloc] initWithString:[paragraphComponents.fullString substringWithRange:NSMakeRange(0, paragraphComponents.fullString.length - 1)]];
    }
    
    NSMutableArray* array = [NSMutableArray array];
    if (normalComponents){
        [array addObject:normalComponents];
    }
    if (paragraphComponents){
        [array addObject:paragraphComponents];
    }
    if (paragraphComponents.tempString.length > 0 ) {
        NSMutableDictionary *stringDict = [NSMutableDictionary dictionaryWithDictionary:@{@"string":paragraphComponents.tempString,@"href":paragraphComponents.hrefs,@"strong":paragraphComponents.boldRanges}];
        if (paragraphComponents.searchRanges) {
            [stringDict setValue:paragraphComponents.searchRanges forKey:@"italic"];
        }
        [paragraphComponents.contentArray addObject:stringDict];
    }
    return [NSArray arrayWithArray:array];
}

+ (void) parseElement:(TFHppleElement *)element
         toComponents:(GHTMLContentMutableComponents *)components
            paragraph:(BOOL)paragraph {
    NSDictionary* elementAttributes = element.attributes;
    NSInteger length = components.tempString.length;
    NSInteger fullLength = components.fullString.length;
    if (element.isTextNode){
        [components.tempString appendString:element.content];
        [components.fullString appendString:element.content];
    }
    for (TFHppleElement* subElement in element.children) {
        [self parseElement:subElement
              toComponents:components
                 paragraph:paragraph];
    }
    if (([element.tagName isEqualToString:@"p"] || [element.tagName isEqualToString:@"br"]) && paragraph) {
        [components.tempString appendString:@"\n"];
        [components.fullString appendString:@"\n"];
    }else if ([element.tagName isEqualToString:@"a"] && [elementAttributes objectForKey:@"href"]) {
        if (!components.tempString || components.tempString.length == 0) {
            return;
        }
        if (fullLength > components.fullString.length) {
            return;
        }
        NSInteger hrefLength = components.fullString.length - fullLength;
        NSInteger location   = (components.fullString.length - hrefLength + components.imageDictCount);
        NSValue* rangeValue  = [NSValue valueWithRange:NSMakeRange(location, hrefLength)];
        [components.hrefs setObject:[elementAttributes objectForKey:@"href"] forKey:rangeValue];
    }else if ([element.tagName isEqualToString:@"b"] || [element.tagName isEqualToString:@"strong"]){
        if (!components.tempString || components.tempString.length == 0) {
            return;
        }
        if (components.tempString.length == length) {
            return;
        }
        if (length > components.tempString.length) {
            return;
        }
        NSRange range = NSMakeRange(length, components.tempString.length - length);
        [components.boldRanges addObject:[NSValue valueWithRange:range]];
    }else if ([element.tagName isEqualToString:@"em"]){
        if (!components.tempString || components.tempString.length == 0)
        {
            return;
        }
        if (length > components.tempString.length)
        {
            return;
        }
        if (components.searchRanges)
        {
            [components.searchRanges addObject:[NSValue valueWithRange:NSMakeRange(length, components.tempString.length - length)]];
        }
        //        DEBUGLOG(@"range is %@",[NSValue valueWithRange:NSMakeRange(length, components.pureString.length - length)]);
    }else if ([element.tagName isEqualToString:@"img"]) {
        NSValue *rangeValue = nil;
        if (components.tempString.length > 0) {
            rangeValue = [NSValue valueWithRange:NSMakeRange(length, components.tempString.length - length)];
        }else {
            rangeValue = [NSValue valueWithRange:NSMakeRange(0, 0)];
        }
        NSDictionary *imgDict = @{rangeValue:elementAttributes};
        [components.imgs addObject:imgDict];
        [[self class] seperatorElement:components];
    }
}

+ (void)seperatorElement:(GHTMLContentMutableComponents *)components {
    if (components.tempString.length > 0) {
        NSMutableDictionary *stringDict = [NSMutableDictionary dictionaryWithDictionary:@{@"string":components.tempString,@"href":components.hrefs,@"strong":components.boldRanges}];
        if (components.searchRanges)  {
            [stringDict setValue:components.searchRanges forKey:@"italic"];
        }
        [components.contentArray addObject:stringDict];
    }
    if (!components.imgs || components.imgs.count == 0) {
        return;
    }
    NSDictionary *imgDict = @{@"img":[components.imgs firstObject]};
    [components.contentArray addObject:imgDict];
    components.tempString = [NSMutableString stringWithFormat:@""];
    components.hrefs      = [NSMutableDictionary dictionary];
    components.boldRanges = [NSMutableArray array];
    components.imageDictCount ++;
    components.imgs       = [NSMutableArray array];
}

@end


