//
//  HTMLParser.m
//  MVendorFramework
//
//  Created by hushaohua on 2017/3/7.
//  Copyright © 2017年 Micker. All rights reserved.
//

#import "HTMLParser.h"
#import "TFHpple.h"

@interface HTMLContentMutableComponents : NSObject

@property (nonatomic, strong) NSMutableString *pureString;
@property (nonatomic, strong) NSMutableDictionary *hrefs; //{Range:Url}
@property (nonatomic, strong) NSMutableArray *boldRanges;
@property (nonatomic, strong) NSMutableArray *searchRanges;
@property (nonatomic, strong) NSMutableArray *imageIndexs;
@property (nonatomic, strong) NSMutableArray *imgs;

@end

@implementation HTMLContentMutableComponents

- (id) initWithOption:(HTMLParserOption)option{
    self = [super init];
    if (self){
        self.pureString = [NSMutableString string];
        if (option & HTMLParserOptionComponentHref){
            self.hrefs = [NSMutableDictionary dictionary];
        }
        if (option & HTMLParserOptionComponentBold){
            self.boldRanges = [NSMutableArray array];
        }
        if (option & HTMLParserOptionComponentSearch){
            self.searchRanges = [NSMutableArray array];
        }
        if (option & HTMLParserOptionComponentImg) {
            self.imgs = [NSMutableArray array];
        }
    }
    return self;
}

@end

@interface HTMLContentComponets()

@property (nonatomic, strong) NSString* pureString;
@property (nonatomic, strong) NSDictionary* hrefs; //{Range:Url}
@property (nonatomic, strong) NSArray* boldRanges;
@property (nonatomic, strong) NSArray* searchRanges;
@property (nonatomic, strong) NSMutableArray *imgs;

@end

@implementation HTMLContentComponets

+ (HTMLContentComponets *) componentsWithString:(NSString *)string
                                               hrefs:(NSDictionary *)hrefs
                                          boldRanges:(NSArray *)boldRanges
                                        searchRanges:(NSArray *)searchRanges{
    HTMLContentComponets* components = [[HTMLContentComponets alloc] init];
    components.pureString = [NSString stringWithString:string];
    components.hrefs = [NSDictionary dictionaryWithDictionary:hrefs];
    components.boldRanges = [NSArray arrayWithArray:boldRanges];
    components.searchRanges = [NSArray arrayWithArray:searchRanges];
    return components;
}

+ (id) componentsWithMutableComponents:(HTMLContentMutableComponents *)mutableComponents{
    HTMLContentComponets* components = [[HTMLContentComponets alloc] init];
    components.pureString = [NSString stringWithString:mutableComponents.pureString];
    components.hrefs = [NSDictionary dictionaryWithDictionary:mutableComponents.hrefs];
    components.boldRanges = [NSArray arrayWithArray:mutableComponents.boldRanges];
    components.searchRanges = [NSMutableArray arrayWithArray:mutableComponents.searchRanges];
    return components;
}

@end

@implementation HTMLParser

+ (NSString *) escapedUrlEncodedStringFrom:(NSString *)string{
    NSMutableString* text = [[NSMutableString alloc] initWithString:string];
    [text replaceOccurrencesOfString:@"&nbsp;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&mdash;" withString:@"--" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&ldquo;" withString:@"“" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    [text replaceOccurrencesOfString:@"&rdquo;" withString:@"”" options:NSLiteralSearch range:NSMakeRange(0, text.length)];
    return text;
}

+ (NSArray *) parserHtmlContent:(NSString *)contentHtml
                         option:(HTMLParserOption)option
      withPLabelWithNotLine: (BOOL )line {
    if (!contentHtml || contentHtml.length == 0) {
        return [NSMutableArray array];
    }
    HTMLContentMutableComponents* normalComponents = nil;
    HTMLContentMutableComponents* paragraphComponents = nil;
    if (option & HTMLParserOptionParagraphNone){
        normalComponents = [[HTMLContentMutableComponents alloc] initWithOption:option];
    }
    if (option & HTMLParserOptionParagraph){
        paragraphComponents = [[HTMLContentMutableComponents alloc] initWithOption:option];
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
                     paragraph:NO
         withPLabelWithNotLine:line];
        }
        if (paragraphComponents){
            [self parseElement:element
                  toComponents:paragraphComponents
                     paragraph:YES
         withPLabelWithNotLine:line];
        }
    }
    if (paragraphComponents.pureString.length == 0) {
        return [NSMutableArray array];
    }
    if ([[paragraphComponents.pureString substringWithRange:NSMakeRange(paragraphComponents.pureString.length - 1, 1)] isEqualToString:@"\n"]) {
        paragraphComponents.pureString = [[NSMutableString alloc] initWithString:[paragraphComponents.pureString substringWithRange:NSMakeRange(0, paragraphComponents.pureString.length - 1)]];
    }
    
    NSMutableArray* array = [NSMutableArray array];
    if (normalComponents){
        [array addObject:normalComponents];
    }
    if (paragraphComponents){
        [array addObject:paragraphComponents];
    }
    return [NSArray arrayWithArray:array];
}

+ (void) parseElement:(TFHppleElement *)element
         toComponents:(HTMLContentMutableComponents *)components
            paragraph:(BOOL)paragraph
    withPLabelWithNotLine: (BOOL )line {
    NSDictionary* elementAttributes = element.attributes;
    NSInteger length = components.pureString.length;
    
    if (element.isTextNode){
        [components.pureString appendString:element.content];
    }
    
    for (TFHppleElement* subElement in element.children) {
        [self parseElement:subElement
              toComponents:components
                 paragraph:paragraph
     withPLabelWithNotLine:line];
    }
    if ([element.tagName isEqualToString:@"p"] && paragraph && !line) {
        [components.pureString appendString:@"\n"];
    }
    if ([element.tagName isEqualToString:@"a"] && [elementAttributes objectForKey:@"href"]){
        if (!components.pureString || components.pureString.length == 0) {
            return;
        }
        NSValue* rangeValue = [NSValue valueWithRange:NSMakeRange(length, components.pureString.length - length)];
        [components.hrefs setObject:[elementAttributes objectForKey:@"href"] forKey:rangeValue];
    }else if ([element.tagName isEqualToString:@"b"] || [element.tagName isEqualToString:@"strong"]){
        if (!components.pureString || components.pureString.length == 0) {
            return;
        }
        [components.boldRanges addObject:[NSValue valueWithRange:NSMakeRange(length, components.pureString.length - length)]];
    }else if ([element.tagName isEqualToString:@"em"]){
        if (!components.pureString || components.pureString.length == 0) {
            return;
        }
        [components.searchRanges addObject:[NSValue valueWithRange:NSMakeRange(length, components.pureString.length - length)]];
    }else if ([element.tagName isEqualToString:@"img"]) {
        if (!components.pureString || components.pureString.length == 0) {
            return;
        }
        NSValue* rangeValue = [NSValue valueWithRange:NSMakeRange(length, components.pureString.length - length)];
        NSDictionary *imgDict = @{rangeValue:elementAttributes};
        [components.imgs addObject:imgDict];
    }
}


@end
