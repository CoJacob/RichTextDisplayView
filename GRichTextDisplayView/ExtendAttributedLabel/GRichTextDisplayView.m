//
//  GRichTextDisplayView.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichTextDisplayView.h"
#import "GRichTextItem.h"
#import "GRichImageItem.h"
#import "GRichTextAttributedLabel.h"
#import "GRichImageView.h"
#import "GRichTextDisplayViewLayout.h"
#import "GRichHtmlTextParser.h"

#import "UIImageView+QNWeb.h"

@interface GRichTextDisplayView () <RichTextAttributedLabelDelegate>

@property (nonatomic, assign) CGFloat                  textFontSize;        // 字体大小
@property (nonatomic, assign) CGFloat                  displayTextWidth;    // 显示宽度
@property (nonatomic, copy)   NSString                 *displayHtmlString;
@property (nonatomic, copy)   NSString                 *retractHtmlString;
@property (nonatomic, strong) GHTMLContentMutableComponents    *component;
@property (nonatomic, strong) GRichTextAttributedLabel *attributedLabel;

@end

@implementation GRichTextDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.attributedLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = self.attributedLabel.frame;
    rect.size.width = self.frame.size.width;
    self.attributedLabel.frame = rect;
}

- (void)setRetractNumberOfLine:(NSInteger)retractNumberOfLine {
    _retractNumberOfLine = retractNumberOfLine;
    if (_retractNumberOfLine) {
        self.attributedLabel.enableRetract = YES;
    }
}

- (void)setIsRetractStatus:(BOOL)isRetractStatus {
    _isRetractStatus = isRetractStatus;
    self.attributedLabel.isRetractStatus = _isRetractStatus;
}

- (void)setHiddenExpandText:(BOOL)hiddenExpandText {
    _hiddenExpandText = hiddenExpandText;
    self.attributedLabel.hiddenExpandText = _hiddenExpandText;
}

- (void)setEnableFoldAndExpand:(BOOL)enableFoldAndExpand {
    _enableFoldAndExpand = enableFoldAndExpand;
    self.attributedLabel.enableFoldAndExpand = enableFoldAndExpand;
}

- (void)triggerFold {
    if (self.enableFoldAndExpand && !self.attributedLabel.isRetractStatus) {
        [self.attributedLabel triggerFold];
    }
}


#pragma mark  - Getter

- (GRichTextAttributedLabel *)attributedLabel {
    if (!_attributedLabel) {
        _attributedLabel = [[GRichTextAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.1)];
        _attributedLabel.lineSpacing = 8;
        _attributedLabel.delegate    = self;
        _attributedLabel.backgroundColor = [UIColor whiteColor];
        _attributedLabel.textColor = [UIColor colorWithRed:(51/255.f) green:(51/255.f) blue:(51/255.f) alpha:1];
        _attributedLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
        _attributedLabel.numberOfLines = 0;
    }
    return _attributedLabel;
}

- (void)displayContentWithHtmlText: (NSString *)htmlText {
    _htmlString = htmlText;
    if (htmlText.length) {
        if (!self.richTextFont) { // 如果没有设置字体, 这里设置默认字体
            self.richTextFont = [UIFont systemFontOfSize:15.f];
        }
        self.textFontSize     = self.richTextFont.pointSize;
        self.attributedLabel.font = self.richTextFont;
        [self displayContentWithHtmlText:_htmlString
                               viewWidth:self.frame.size.width
                                fontSize:self.textFontSize];
    }
}


#pragma mark  -

- (CGFloat )displayContentWithHtmlText: (NSString *)htmlText
                             viewWidth: (CGFloat )width
                              fontSize: (CGFloat )fontSize {
    if (htmlText.length == 0) {
        CGRect rect = self.frame;
        rect.size.height = 0;
        self.frame = rect;
        return 0;
    }
    if ([self.displayHtmlString isEqualToString:htmlText] && width == self.displayTextWidth) {
        return 0;
    }
    [self removeSubViewsAndCleanAttributedLabelText];
    
    NSArray *componenets = [GRichHtmlTextParser parserHtmlContent:htmlText option:(GHTMLParserOptionParagraph |GHTMLParserOptionComponentBold | GHTMLParserOptionComponentHref |
                                                                                   GHTMLParserOptionComponentImg | GHTMLParserOptionComponentSearch)];
    GHTMLContentMutableComponents *component = componenets.firstObject;
    self.displayHtmlString = htmlText;
    self.displayTextWidth  = width;
    self.component         = component;
    CGFloat _textHeight = 0;

    if (self.retractNumberOfLine) {
        NSInteger numberOfLine = [GRichTextDisplayViewLayout numberOflinesOfStringForString:component.fullString
                                                                                       font:self.richTextFont
                                                                                      width:width];
        if (numberOfLine > _retractNumberOfLine && self.isRetractStatus) {
            self.attributedLabel.numberOfLines = _retractNumberOfLine;
            _textHeight = [self displayAttributedLabelContentWithComponent:component
                                                                     width:width
                                                                 ignoreImg:YES];
        }else {
            _textHeight = [self displayAttributedLabelContentWithComponent:component
                                                                     width:width
                                                                 ignoreImg:NO];
        }
    }else {
        _textHeight = [self displayAttributedLabelContentWithComponent:component
                                                                 width:width
                                                             ignoreImg:NO];
    }
    return _textHeight;
}

- (void)removeSubViewsAndCleanAttributedLabelText {
    if (self.displayHtmlString.length) {
        CGRect rect = self.attributedLabel.frame;
        rect.size.height = 0;
        self.attributedLabel.frame = rect;
        self.attributedLabel.text           = @"";
        self.attributedLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];
    }
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
}

- (CGFloat )displayAttributedLabelContentWithComponent: (GHTMLContentMutableComponents *)component
                                                 width: (CGFloat )width
                                             ignoreImg: (BOOL )ignoreImg {
    if (component.contentArray.count > 0) {
        [component.contentArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj allKeys] containsObject:@"string"]) {
                [self appendTextViewWithTextElement:obj];
            }else if ([[obj allKeys] containsObject:@"img"] && !ignoreImg) {
                [self appendImgeViewWithElement:obj];
            }
        }];
    }else {
        [self.attributedLabel appendAttributedText:[self defaultArrtibutedStringWithText:component.fullString]];
    }
    
    CGSize labelSize       = [self.attributedLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGRect labelRect = self.attributedLabel.frame;
    labelRect.size.height = labelSize.height;
    self.attributedLabel.frame = labelRect;
    CGRect rect = self.frame;
    rect.size.height = labelSize.height;
    self.frame = rect;
    return labelSize.height;
}

- (CGFloat )contentHeight {
    return self.attributedLabel.frame.size.height;
}

- (void)updateAttributedLabelFrameHeight {
    CGSize labelSize = [self.attributedLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    CGRect rect = self.attributedLabel.frame;
    rect.size.height = labelSize.height;
    self.attributedLabel.frame = rect;
}

#pragma mark  - Private

- (NSMutableAttributedString *)defaultArrtibutedStringWithText: (NSString *)text {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.textFontSize],
                                                                                                          NSForegroundColorAttributeName:[UIColor cg_getColor:@"333333"]
                                                                                                          }]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing              = 8;
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

- (void)appendImgeViewWithElement: (NSDictionary *)imgDict {
    GRichImageItem *imageItem = [[GRichImageItem alloc] initWithContent:imgDict width:self.bounds.size.width];
    GRichImageView *imageView    = [[GRichImageView alloc] initWithFrame:CGRectMake(0, self.attributedLabel.frame.size.height, self.frame.size.width, 0.1)];
    imageView.clipsToBounds   = YES;
    imageView.contentMode     = UIViewContentModeScaleAspectFill;
    
    if (imageItem.width < CGRectGetWidth(self.frame)) {
        imageView.frame = CGRectMake((CGRectGetWidth(self.frame) - imageItem.width)/2.0f, self.attributedLabel.frame.size.height, imageItem.width, imageItem.height);
    }else {
        imageView.frame = CGRectMake(0, self.attributedLabel.frame.size.height, imageItem.width, imageItem.height);
    }
    CGFloat _originFrameY = CGRectGetMaxY(self.attributedLabel.frame);
    UIImage *placeholderImage = [[UIImage imageNamed:@"wscn_w"] drawRectImageWithBorderColor:[UIColor blackColor] size:CGSizeMake(imageItem.width, imageItem.height)];
    UIImage *attachementImage = placeholderImage;
    imageView.imageUrl = imageItem.src;
    
    [self.attributedLabel appendImage:attachementImage maxSize:CGSizeMake(self.frame.size.width, imageItem.height)];
    [self updateAttributedLabelFrameHeight];
    if (self.enableImgSeamlessSititching) {
        CGFloat _targetHeight = CGRectGetMaxY(self.attributedLabel.frame) - _originFrameY;
        if (imageItem.width < CGRectGetWidth(self.frame)) {
            imageView.frame = CGRectMake((CGRectGetWidth(self.frame) - imageItem.width)/2.0f, _originFrameY, imageItem.width, _targetHeight);
        }else {
            imageView.frame = CGRectMake(0, _originFrameY, imageItem.width, _targetHeight);
        }
    }
    [imageView qn_setClipSizedImageWithUrl:imageItem.src placeholder:placeholderImage];
    [self addSubview:imageView];
}

- (void)appendTextViewWithTextElement: (NSDictionary *)textDict {
    GRichTextItem *textItem = [[GRichTextItem alloc] initWithContent:textDict fontSize:self.textFontSize];
    if ([textItem.attributedString string].length == 0) {
        return ;
    }
    
    [self.attributedLabel appendAttributedText:textItem.attributedString];
    [self updateAttributedLabelFrameHeight];
    if ([textItem.hrefDict allKeys].count > 0) {
        [textItem.hrefDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString *linkUrl, BOOL * _Nonnull stop) {
            NSValue *rangeValue = (NSValue *)key;
            NSRange range       = [rangeValue rangeValue];
            
            if ((range.length + range.location) <= [self.attributedLabel.attributedText string].length) {
                NSString *hrefString = [[self.attributedLabel.attributedText string] substringWithRange:range];
                if ([[textItem.attributedString string] containsString:hrefString]) {
                    NSString *url = (NSString *)linkUrl;
                    [self.attributedLabel addCustomLink:url forRange:range linkColor:[UIColor cg_getColor:@"1482f0"]];
                }
            }
        }];
    }
    
    if (textItem.italicArray.count) {
        for (NSValue *rangeValue in textItem.italicArray) {
            NSRange range = [rangeValue rangeValue];
            if ((range.length + range.location) <= [self.attributedLabel.attributedText string].length) {
                [self.attributedLabel addCustomItalicForRange:range];
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

#pragma mark  - RichTextAttributedLabelDelegate

- (void)richTextAttributedLabel:(GrichTextAttributedLabel *_Nullable)label
                  clickedOnLink:(id _Nullable)linkData {
    NSString *urlString = linkData;
    if (urlString.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KOPENRICHVIEWROUTRLINKNOTIFICATION" object:nil];
//        [[MRouter sharedRouter] handleURL:[NSURL URLWithString:urlString] userInfo:nil];
    }
}

- (void)richTextAttributedLabel:(GrichTextAttributedLabel *)label
             clickRetractButton:(BOOL)retract {
    self.isRetractStatus = retract;
    self.attributedLabel.numberOfLines = (retract) ? self.retractNumberOfLine : 0;
    [self removeSubViewsAndCleanAttributedLabelText];
    [self displayAttributedLabelContentWithComponent:self.component
                                               width:self.displayTextWidth
                                           ignoreImg:self.isRetractStatus];
    !self.retratHandle?:self.retratHandle();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.retractNumberOfLine != 0 ) {
        if (self.isRetractStatus) {
            [self.attributedLabel triggerFold];
        }
    }
}


@end
