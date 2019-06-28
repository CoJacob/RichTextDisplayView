//
//  GRichTextAttributedLabel.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichTextAttributedLabel.h"
#import "GRichTextAttributedLabelAttachment.h"
#import "GRichTextAttributedLabelURL.h"
#import "GRichTextAttributedLabeItalic.h"
#import "GRichTextAttributedLabelDefines.h"

static NSString * const RichTxtEllipsesCharacter = @"\u2026"; // 省略号
NSString * const GTextGlyphTransformAttributeName = @"GTextGlyphTransform";

static dispatch_queue_t rt_attributed_label_parse_queue;
static dispatch_queue_t get_rt_attributed_label_parse_queue() \
{
    if (rt_attributed_label_parse_queue == NULL) {
        rt_attributed_label_parse_queue = dispatch_queue_create("com.rt.parse_queue", 0);
    }
    return rt_attributed_label_parse_queue;
}

@interface GRichTextAttributedLabel ()
{
    NSMutableArray              *_attachments;
    NSMutableArray              *_linkLocations;
    NSMutableArray              *_italicLocations;
    CTFrameRef                  _textFrame;
    CGFloat                     _fontAscent;
    CGFloat                     _fontDescent;
    CGFloat                     _fontHeight;
}
@property (nonatomic,strong)    NSMutableAttributedString *attributedString;
@property (nonatomic,strong)    GRichTextAttributedLabelURL *touchedLink;
@property (nonatomic, strong)   UIButton *moreButton;
@property (nonatomic, strong)   UIColor *textFillColor;
@property (nonatomic, assign)   NSRange textFillColorRange;
@property (nonatomic,assign)    BOOL linkDetected;
@property (nonatomic,assign)    BOOL ignoreRedraw;
@end

@implementation GRichTextAttributedLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    if (_textFrame) {
        CFRelease(_textFrame);
    }
}

#pragma mark - 初始化
- (void)commonInit {
    _attributedString       = [[NSMutableAttributedString alloc]init];
    _attachments            = [[NSMutableArray alloc]init];
    _linkLocations          = [[NSMutableArray alloc]init];
    _italicLocations        = [[NSMutableArray alloc] init];
    _textFrame              = nil;
    _linkColor              = [UIColor colorWithRed:(20/255.f) green:(130/255.f) blue:(240/255.f) alpha:1];
    _font                   = [UIFont systemFontOfSize:15];
    _textColor              = [UIColor blackColor];
    _highlightColor         = [UIColor colorWithRed:0xd7/255.0
                                              green:0xf2/255.0
                                               blue:0xff/255.0
                                              alpha:1];
    _lineBreakMode          = kCTLineBreakByWordWrapping;
    _underLineForLink       = YES;
    _autoDetectLinks        = YES;
    _lineSpacing            = 0.0;
    _paragraphSpacing       = 0.0;
    
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.userInteractionEnabled = YES;
    [self resetFont];
    [self addSubview:self.moreButton];
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.frame = CGRectZero;
        [_moreButton setTitleColor:[UIColor colorWithRed:(20/255.f) green:(130/255.f) blue:(240/255.f) alpha:1] forState:UIControlStateNormal];
        [_moreButton setTitle:@"展开" forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _moreButton.hidden = YES;
        [_moreButton addTarget:self
                        action:@selector(moreAction:)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (void)cleanAll {
    _ignoreRedraw = NO;
    _linkDetected = NO;
    [_attachments removeAllObjects];
    [_linkLocations removeAllObjects];
    self.touchedLink = nil;
    for (UIView *subView in self.subviews) {
        if (![subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    [self resetTextFrame];
}


- (void)resetTextFrame {
    if (_textFrame) {
        CFRelease(_textFrame);
        _textFrame = nil;
    }
    if ([NSThread isMainThread] && !_ignoreRedraw) {
        [self setNeedsDisplay];
    }
}

- (void)resetFont {
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    if (fontRef) {
        _fontAscent     = CTFontGetAscent(fontRef);
        _fontDescent    = CTFontGetDescent(fontRef);
        _fontHeight     = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
}

#pragma mark - 属性设置
//保证正常绘制，如果传入nil就直接不处理
- (void)setFont:(UIFont *)font {
    if (font && _font != font) {
        _font = font;
        
        [_attributedString rt_setFont:_font];
        [self resetFont];
        for (GRichTextAttributedLabelAttachment *attachment in _attachments) {
            attachment.fontAscent = _fontAscent;
            attachment.fontDescent = _fontDescent;
        }
        self.moreButton.titleLabel.font = font;
        [self resetTextFrame];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor && _textColor != textColor) {
        _textColor = textColor;
        [_attributedString rt_setTextColor:textColor];
        [self resetTextFrame];
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    if (highlightColor && _highlightColor != highlightColor) {
        _highlightColor = highlightColor;
        
        [self resetTextFrame];
    }
}

- (void)setLinkColor:(UIColor *)linkColor {
    if (_linkColor != linkColor) {
        _linkColor = linkColor;
        [self resetTextFrame];
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect oldRect = self.bounds;
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

- (void)setBounds:(CGRect)bounds {
    CGRect oldRect = self.bounds;
    [super setBounds:bounds];
    
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        [self resetTextFrame];
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        [self resetTextFrame];
    }
}

- (void)setShadowBlur:(CGFloat)shadowBlur {
    if (_shadowBlur != shadowBlur) {
        _shadowBlur = shadowBlur;
        [self resetTextFrame];
    }
}

#pragma mark - 辅助方法
- (NSAttributedString *)attributedString:(NSString *)text {
    if ([text length]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
        [string rt_setFont:self.font];
        [string rt_setTextColor:self.textColor];
        return string;
    }else {
        return [[NSAttributedString alloc] init];
    }
}

- (NSInteger)numberOfDisplayedLines {
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    return _numberOfLines > 0 ? MIN(CFArrayGetCount(lines), _numberOfLines) : CFArrayGetCount(lines);
}

- (NSAttributedString *)attributedStringForDraw {
    if (_attributedString) {
        //添加排版格式
        NSMutableAttributedString *drawString = [_attributedString mutableCopy];
        
        //如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
        CTLineBreakMode lineBreakMode = self.lineBreakMode;
        if (self.lineBreakMode == kCTLineBreakByTruncatingTail) {
            lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByTruncatingTail : kCTLineBreakByWordWrapping;
        }
        CGFloat fontLineHeight = self.font.lineHeight;  //使用全局fontHeight作为最小lineHeight
        
        
        CTParagraphStyleSetting settings[] =
        {
            {kCTParagraphStyleSpecifierAlignment,sizeof(_textAlignment),&_textAlignment},
            {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},
            {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
            {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(_paragraphSpacing),&_paragraphSpacing},
            {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(fontLineHeight),&fontLineHeight},
        };
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
        [drawString addAttribute:(id)kCTParagraphStyleAttributeName
                           value:(__bridge id)paragraphStyle
                           range:NSMakeRange(0, [drawString length])];
        CFRelease(paragraphStyle);
        
        
        
        for (GRichTextAttributedLabelURL *url in _linkLocations) {
            if (url.range.location + url.range.length >[_attributedString length]) {
                continue;
            }
            UIColor *drawLinkColor = self.linkColor;
            [drawString rt_setTextColor:drawLinkColor range:url.range];
//            [drawString rt_setUnderlineStyle:_underLineForLink ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone
//                                     modifier:kCTUnderlinePatternSolid
//                                        range:url.range];
        }
        
        for (GRichTextAttributedLabeItalic *italic in _italicLocations) {
            if (italic.range.location + italic.range.length >[_attributedString length]) {
                continue;
            }
            UIColor *drawItalicColor = self.textColor;
            [drawString rt_setItalicForRange:italic.range color:drawItalicColor];
        }
        return drawString;
    }else {
        return nil;
    }
}

- (GRichTextAttributedLabelURL *)urlForPoint:(CGPoint)point {
    static const CGFloat kVMargin = 5;
    if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), point)
        || !_textFrame) {
        return nil;
    }
    
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    if (!lines)
        return nil;
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0,0), origins);
    
    CGAffineTransform transform = [self transformForCoreText];
    CGFloat verticalOffset = 0; //统一是TOP,那么offset就为0
    
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        rect = CGRectInset(rect, 0, -kVMargin);
        rect = CGRectOffset(rect, 0, verticalOffset);
        
        if (CGRectContainsPoint(rect, point)) {
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            GRichTextAttributedLabelURL *url = [self linkAtIndex:idx];
            if (url) {
                return url;
            }
        }
    }
    return nil;
}


- (id)linkDataForPoint:(CGPoint)point {
    GRichTextAttributedLabelURL *url = [self urlForPoint:point];
    return url ? url.linkData : nil;
}

- (CGAffineTransform)transformForCoreText {
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (GRichTextAttributedLabelURL *)linkAtIndex:(CFIndex)index {
    for (GRichTextAttributedLabelURL *url in _linkLocations) {
        if (NSLocationInRange(index, url.range)) {
            return url;
        }
    }
    return nil;
}


- (CGRect)rectForRange:(NSRange)range
                inLine:(CTLineRef)line
            lineOrigin:(CGPoint)lineOrigin {
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
    // intersect with the range.
    for (CFIndex k = 0; k < runCount; k++) {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        CFRange stringRunRange = CTRunGetStringRange(run);
        NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
        NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
        
        if (intersectedRunRange.length == 0) {
            // This run doesn't intersect the range, so skip it.
            continue;
        }
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        
        // Use of 'leading' doesn't properly highlight Japanese-character link.
        CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                           CFRangeMake(0, 0),
                                                           &ascent,
                                                           &descent,
                                                           NULL); //&leading);
        CGFloat height = ascent + descent;
        
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
        
        CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

- (void)appendAttachment:(GRichTextAttributedLabelAttachment *)attachment {
    attachment.fontAscent                   = _fontAscent;
    attachment.fontDescent                  = _fontDescent;
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)attachment);
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
    [attachText setAttributes:attr range:NSMakeRange(0, 1)];
    CFRelease(delegate);
    
    [_attachments addObject:attachment];
    [self appendAttributedText:attachText];
}


#pragma mark - 设置文本
- (void)setText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    [_attributedString rt_setFont:self.font];
    [self cleanAll];
}

- (NSString *)text {
    return [_attributedString string];
}

- (NSAttributedString *)attributedText {
    return [_attributedString copy];
}

#pragma mark - 添加文本
- (void)appendText:(NSString *)text {
    NSAttributedString *attributedText = [self attributedString:text];
    [self appendAttributedText:attributedText];
}

- (void)appendAttributedText:(NSAttributedString *)attributedText {
    [_attributedString appendAttributedString:attributedText];
    [self resetTextFrame];
}


#pragma mark - 添加图片
- (void)appendImage:(UIImage *)image {
    [self appendImage:image
              maxSize:image.size];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize {
    [self appendImage:image
              maxSize:maxSize
               margin:UIEdgeInsetsZero];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin {
    [self appendImage:image
              maxSize:maxSize
               margin:margin
            alignment:RichTextImageAlignmentBottom];
}

- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin
          alignment:(RichTextImageAlignment)alignment {
    GRichTextAttributedLabelAttachment *attachment = [GRichTextAttributedLabelAttachment attachmentWith:image
                                                                                     margin:margin
                                                                                  alignment:alignment
                                                                                    maxSize:maxSize];
    [self appendAttachment:attachment];
}

#pragma mark - 添加UI控件
- (void)appendView:(UIView *)view {
    [self appendView:view
              margin:UIEdgeInsetsZero];
}

- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin {
    [self appendView:view
              margin:margin
           alignment:RichTextImageAlignmentBottom];
}


- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin
         alignment:(RichTextImageAlignment)alignment {
    GRichTextAttributedLabelAttachment *attachment = [GRichTextAttributedLabelAttachment attachmentWith:view
                                                                                     margin:margin
                                                                                  alignment:alignment
                                                                                    maxSize:CGSizeZero];
    [self appendAttachment:attachment];
}

#pragma mark - 自定义颜色

- (void)addCustomTextFillColor: (UIColor *)fillColor
                      forRange:(NSRange)range {
    self.textFillColor = fillColor;
    self.textFillColorRange = range;
    [self resetTextFrame];
}

#pragma mark - 添加链接
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range {
    [self addCustomLink:linkData
               forRange:range
              linkColor:self.linkColor];
    
}

- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range
            linkColor:(UIColor *)color {
    if (color) {
        _linkColor = color;
    }
    GRichTextAttributedLabelURL *url = [GRichTextAttributedLabelURL urlWithLinkData:linkData
                                                                  range:range
                                                                  color:color];
    [_linkLocations addObject:url];
    [self resetTextFrame];
}

- (void)addCustomItalicForRange: (NSRange)range {
    GRichTextAttributedLabeItalic *italic = [GRichTextAttributedLabeItalic italicWithRange:range
                                                                                     color:_textColor];
    [_italicLocations addObject:italic];
    [self resetTextFrame];
}

#pragma mark - 计算大小
- (CGSize)sizeThatFits:(CGSize)size
{
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (!drawString) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
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


- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
}


#pragma mark - 绘制方法
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx )
    {
        return;
    }
    CGContextSaveGState(ctx);
    CGAffineTransform transform = [self transformForCoreText];
    CGContextConcatCTM(ctx, transform);
    
    [self recomputeLinksIfNeeded];
    
    NSAttributedString *drawString =  [self attributedStringForDraw];
    if (drawString)
    {
        [self prepareTextFrame:drawString rect:rect];
        [self drawHighlightWithRect:rect];
        [self drawCustomFillColorWithRect:rect];
        [self drawAttachments];
        [self drawShadow:ctx];
        [self drawText:drawString
                  rect:rect
               context:ctx];
    }
    CGContextRestoreGState(ctx);
}

- (void)prepareTextFrame:(NSAttributedString *)string
                    rect:(CGRect)rect
{
    if (!_textFrame)
    {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,rect);
        _textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
}

- (void)drawHighlightWithRect:(CGRect)rect
{
    if (self.touchedLink && self.highlightColor)
    {
        [self drawCustomColorWithRect:rect
                                color:self.highlightColor
                                range:self.touchedLink.range];
    }
}

- (void)drawCustomFillColorWithRect:(CGRect)rect {
    if (self.textFillColor) {
        [self drawCustomColorWithRect:rect
                                color:self.textFillColor
                                range:self.textFillColorRange];
    }
}

- (void)drawCustomColorWithRect: (CGRect )rect color: (UIColor *)color range: (NSRange )range {
    if (color)
    {
        [color setFill];
        NSRange linkRange = range;
        
        CFArrayRef lines = CTFrameGetLines(_textFrame);
        CFIndex count = CFArrayGetCount(lines);
        CGPoint lineOrigins[count];
        CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);
        NSInteger numberOfLines = [self numberOfDisplayedLines];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        for (CFIndex i = 0; i < numberOfLines; i++)
        {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CFRange stringRange = CTLineGetStringRange(line);
            NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
            NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
            if (intersectedRange.length == 0) {
                continue;
            }
            
            CGRect highlightRect = [self rectForRange:linkRange
                                               inLine:line
                                           lineOrigin:lineOrigins[i]];
            highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
            if (!CGRectIsEmpty(highlightRect))
            {
                CGFloat pi = (CGFloat)M_PI;
                
                CGFloat radius = 1.0f;
                CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius,
                                radius, pi, pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                                        highlightRect.origin.y + highlightRect.size.height);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                                highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
                CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius,
                                radius, 0.0f, -pi / 2.0f, 1.0f);
                CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
                CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius,
                                -pi / 2, pi, 1);
                CGContextFillPath(ctx);
            }
        }
        
    }
}

- (void)drawShadow:(CGContextRef)ctx
{
    if (self.shadowColor)
    {
        CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    }
}

- (void)drawText:(NSAttributedString *)attributedString
            rect:(CGRect)rect
         context:(CGContextRef)context
{
    if (_textFrame)
    {
        if (_italicLocations.count > 0) {
            [self drawInclineFont];
        }
        if (_numberOfLines > 0)
        {
            CFArrayRef lines = CTFrameGetLines(_textFrame);
            NSInteger numberOfLines = [self numberOfDisplayedLines];
            
            CGPoint lineOrigins[numberOfLines];
            CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
            
            for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
            {
                CGPoint lineOrigin = lineOrigins[lineIndex];
                CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
                CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
                BOOL shouldDrawLine = YES;
                if (lineIndex == numberOfLines - 1 &&
                    _lineBreakMode == kCTLineBreakByTruncatingTail)
                {
                    //找到最后一行并检查是否需要 truncatingTail
                    CFRange lastLineRange = CTLineGetStringRange(line);
                    if (lastLineRange.location + lastLineRange.length < attributedString.length)
                    {
                        CTLineTruncationType truncationType = kCTLineTruncationEnd;
                        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                        
                        NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                             effectiveRange:NULL];
                        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:RichTxtEllipsesCharacter
                                                                                          attributes:tokenAttributes];
                        CTLineRef truncationToken = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                        
                        NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                        
                        if (lastLineRange.length) {
                            //移除掉最后一个对象...
                            if (self.enableRetract && self.isRetractStatus ) {
                                if (lastLineRange.length > 5 && !self.hiddenExpandText) {
                                    [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 5, 5)];
                                }
//                                if (self.hiddenExpandText) {
//                                    if (lastLineRange.length > 3) {
//                                        [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 3, 3)];
//                                    }
//                                }
                            }else {
                                [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                            }
                        }
                        [truncationString appendAttributedString:tokenString];
                        
                        
                        CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                        if (!truncatedLine) {
                            truncatedLine = CFRetain(truncationToken);
                        }
                        CFRelease(truncationLine);
                        CFRelease(truncationToken);
                        
                        CTLineDraw(truncatedLine, context);
                        CFRelease(truncatedLine);
                        
                        shouldDrawLine = NO;
                    }
                    
                    
                    if (self.enableRetract && !self.hiddenExpandText) {
                        [self.moreButton sizeToFit];
                        {
                            //获取此行中每个CTRun
                            CFArrayRef runs = CTLineGetGlyphRuns(line);
                            CGFloat runAscent;//此CTRun上缘线
                            CGFloat runDescent;//此CTRun下缘线
                            CGPoint lineOrigin = lineOrigins[0];//此行起点
                            CTRunRef run = CFArrayGetValueAtIndex(runs, 0);//获取此CTRun
                            
                            CGRect runRect;
                            //获取此CTRun的上缘线，下缘线,并由此获取CTRun和宽度
                            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                            
                            //CTRun的X坐标
                            CGFloat runOrgX = lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                            runRect = CGRectMake(runOrgX,lineOrigin.y-runDescent,runRect.size.width,runAscent+runDescent);
                            
                            self.moreButton.frame = CGRectMake(rect.size.width-CGRectGetWidth(self.moreButton.frame),runRect.origin.y - runAscent/2.0 + runDescent, CGRectGetWidth(self.moreButton.frame), runRect.size.height);
                            [self.moreButton setHidden:!self.isRetractStatus];
                        }
                    }
                }
                
                if(shouldDrawLine) {
                    if (_italicLocations.count <= 0) {
                        CTLineDraw(line, context);
                    }
//                    CTLineDraw(line, context);
                    
                }
                
            }
        }
        else
        {
            if (_italicLocations.count <= 0) {
                CTFrameDraw(_textFrame,context);
            }
//            CTFrameDraw(_textFrame,context);
            
        }
    }
}

- (void)drawInclineFont {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    NSInteger numberOfLines = [self numberOfDisplayedLines];
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
    {
        if (lineIndex == numberOfLines - 1 &&
            _lineBreakMode == kCTLineBreakByTruncatingTail && _numberOfLines > 0) {
            return;
        }
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CGFloat posX = lineOrigin.x ;
        CGFloat posY = CGRectGetHeight(self.frame) - lineOrigin.y;
        CGContextSetTextPosition(context, posX, posY);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        for (CFIndex k = 0; k < runCount; k++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextSetTextPosition(context, posX, posY);
            
            CFDictionaryRef runAttrs = CTRunGetAttributes(run);
            CGColorRef fillColor = (CGColorRef)CFDictionaryGetValue(runAttrs, kCTForegroundColorAttributeName);
            if (!CGColorEqualToColor(fillColor, _linkColor.CGColor)) {
                fillColor = _textColor.CGColor;
            }
            CGContextSetFillColorWithColor(context, fillColor);
            
            CTFontRef runFont = CFDictionaryGetValue(runAttrs, kCTFontAttributeName);
            if (!runFont) return;
            NSUInteger glyphCount = CTRunGetGlyphCount(run);
            if (glyphCount <= 0) return;
            CGGlyph glyphs[glyphCount];
            CGPoint glyphPositions[glyphCount];
            CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs);
            CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions);
            
            NSValue *glyphTransformValue = CFDictionaryGetValue(runAttrs, (__bridge const void *)(GTextGlyphTransformAttributeName));
            
            {
                CFIndex runStrIdx[glyphCount + 1];
                CTRunGetStringIndices(run, CFRangeMake(0, 0), runStrIdx);
                CFRange runStrRange = CTRunGetStringRange(run);
                runStrIdx[glyphCount] = runStrRange.location + runStrRange.length;
                CGSize glyphAdvances[glyphCount];
                CTRunGetAdvances(run, CFRangeMake(0, 0), glyphAdvances);
                
                CGPoint zeroPoint = CGPointZero;
                
                
                for (NSUInteger g = 0; g < glyphCount; g++) {
                    CGContextSaveGState(context); {
                        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                        
                        if (glyphTransformValue) {
                            CGAffineTransform glyphTransform = glyphTransformValue.CGAffineTransformValue;
                            CGContextSetTextMatrix(context, glyphTransform);
                        }else {
                            CGAffineTransform normalTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
                            CGContextSetTextMatrix(context, normalTransform);
                        }
                        CGFloat _originY =  (lineOrigin.y + glyphPositions[g].y);
                        CGContextSetTextPosition(context,
                                                 lineOrigin.x + glyphPositions[g].x,
                                                 _originY);
                        
                        {
                            CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
                            CGContextSetFont(context, cgFont);
                            CGContextSetFontSize(context, CTFontGetSize(runFont));
                            CGContextShowGlyphsAtPositions(context, glyphs + g, &zeroPoint, 1);
                            CGFontRelease(cgFont);
                        }
                    } CGContextRestoreGState(context);
                }
            }
            CGContextSaveGState(context);
            CGContextRestoreGState(context);
        }
        
    }
    
}

- (void)drawAttachments {
    if ([_attachments count] == 0) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);
    NSInteger numberOfLines = [self numberOfDisplayedLines];
    for (CFIndex i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        //遍历以找到对应的 attachment 进行绘制
        for (CFIndex k = 0; k < runCount; k++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (!delegate) {
                continue;
            }
            GRichTextAttributedLabelAttachment* attributedImage = (GRichTextAttributedLabelAttachment *)CTRunDelegateGetRefCon(delegate);
            
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                               CFRangeMake(0, 0),
                                                               &ascent,
                                                               &descent,
                                                               NULL);
            
            CGFloat imageBoxHeight = [attributedImage boxSize].height;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (attributedImage.alignment)
            {
                case RichTextImageAlignmentTop:
                {
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                }
                    break;
                case RichTextImageAlignmentCenter:
                {
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                }
                    break;
                case RichTextImageAlignmentBottom:
                {
                    imageBoxOriginY = lineBottomY;
                }
                    break;
            }
            
            CGRect rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight - self.lineSpacing);
            UIEdgeInsets flippedMargins = attributedImage.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
            if (rect.size.height != lineHeight) {
                CGFloat _space = (rect.size.height - lineHeight)/2.0f;
                if (rect.size.height > lineHeight) {
                    attatchmentRect.origin.y += _space;
                }else {
                    attatchmentRect.origin.y -= _space;
                }
            }
            
            if (i == numberOfLines - 1 &&
                k >= runCount - 2 &&
                _lineBreakMode == kCTLineBreakByTruncatingTail) {
                //最后行最后的2个CTRun需要做额外判断
                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
                const CGFloat kMinEllipsesWidth = attachmentWidth;
                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth) {
                    continue;
                }
            }
            
            
            id content = attributedImage.content;
            if ([content isKindOfClass:[UIImage class]]) {
                CGContextDrawImage(ctx, attatchmentRect, ((UIImage *)content).CGImage);
            }else if ([content isKindOfClass:[UIView class]]) {
                UIView *view = (UIView *)content;
                if (!view.superview) {
                    [self addSubview:view];
                }
                CGRect viewFrame = CGRectMake(attatchmentRect.origin.x,
                                              self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,
                                              attatchmentRect.size.width,
                                              attatchmentRect.size.height);
                [view setFrame:viewFrame];
            }else {
//                NSLog(@"Attachment Content Not Supported %@",content);
            }
            
        }
    }
}

#pragma mark - IBAction

- (void)moreAction: (UIButton *)button {
    [self triggerFold];
}

- (void)triggerFold {
    self.isRetractStatus = !self.isRetractStatus;
    [self.moreButton setHidden:!self.isRetractStatus];
    if (_delegate && [_delegate respondsToSelector:@selector(richTextAttributedLabel:clickRetractButton:)]) {
        [_delegate richTextAttributedLabel:(id)self clickRetractButton:self.isRetractStatus];
    }
}

#pragma mark - 点击事件处理
- (BOOL)onLabelClick:(CGPoint)point {
    id linkData = [self linkDataForPoint:point];
    if (linkData) {
        if (_delegate && [_delegate respondsToSelector:@selector(richTextAttributedLabel:clickedOnLink:)]) {
            [_delegate richTextAttributedLabel:(id)self clickedOnLink:linkData];
        }else {
            NSURL *url = nil;
            if ([linkData isKindOfClass:[NSString class]]) {
                url = [NSURL URLWithString:linkData];
            }else if([linkData isKindOfClass:[NSURL class]]) {
                url = linkData;
            }
            if ([url absoluteString].length) {
//                [[MRouter sharedRouter] handleURL:url userInfo:nil];
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        return YES;
    }
    
    return NO;
}


#pragma mark - 链接处理

- (void)recomputeLinksIfNeeded {
    const NSInteger kMinHttpLinkLength = 5;
    if (!_autoDetectLinks || _linkDetected) {
        return;
    }
    NSString *text = [[_attributedString string] copy];
    NSUInteger length = [text length];
    if (length <= kMinHttpLinkLength) {
        return;
    }
    BOOL sync = length <= RichTextMinAsyncDetectLinkLength;
    [self computeLink:text
                 sync:sync];
}

- (void)computeLink:(NSString *)text
               sync:(BOOL)sync {
    __weak typeof(self) weakSelf = self;
    typedef void (^LinkBlock) (NSArray *);
    LinkBlock block = ^(NSArray *links){
        weakSelf.linkDetected = YES;
        if ([links count]) {
            for (GRichTextAttributedLabelURL *link in links) {
                [weakSelf addAutoDetectedLink:link];
            }
            [weakSelf resetTextFrame];
        }
    };
    
    if (sync) {
        _ignoreRedraw = YES;
        NSArray *links = [GRichTextAttributedLabelURL detectLinks:text];
        block(links);
        _ignoreRedraw = NO;
    }else {
        dispatch_async(get_rt_attributed_label_parse_queue(), ^{
            
            NSArray *links = [GRichTextAttributedLabelURL detectLinks:text];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *plainText = [[weakSelf attributedString] string];
                if ([plainText isEqualToString:text]) {
                    block(links);
                }
            });
        });
    }
}

- (void)addAutoDetectedLink:(GRichTextAttributedLabelURL *)link {
    NSRange range = link.range;
    for (GRichTextAttributedLabelURL *url in _linkLocations) {
        if (NSIntersectionRange(range, url.range).length != 0) {
            return;
        }
    }
    [self addCustomLink:link.linkData
               forRange:link.range];
}

#pragma mark - 点击事件相应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.touchedLink) {
        UITouch *touch = [touches anyObject];
        CGPoint point  = [touch locationInView:self];
        self.touchedLink =  [self urlForPoint:point];
    }
    
    
    if (self.touchedLink) {
        [self setNeedsDisplay];
    }else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    GRichTextAttributedLabelURL *touchedLink = [self urlForPoint:point];
    if (self.touchedLink != touchedLink) {
        self.touchedLink = touchedLink;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self];
    if(![self onLabelClick:point]) {
        [super touchesEnded:touches withEvent:event];
    }
    if (self.touchedLink) {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
//{
//    GRichTextAttributedLabelURL *touchedLink = [self urlForPoint:point];
//    if (!touchedLink)
//    {
//        NSArray *subViews = [self subviews];
//        for (UIView *view in subViews)
//        {
//            CGPoint hitPoint = [view convertPoint:point
//                                         fromView:self];
//            
//            UIView *hitTestView = [view hitTest:hitPoint
//                                      withEvent:event];
//            if (hitTestView)
//            {
//                return hitTestView;
//            }
//        }
//        return nil;
//    }
//    else
//    {
//        return self;
//    }
//}

#pragma mark - 设置自定义的链接检测block
+ (void)setCustomDetectMethod:(RichTextCustomDetectLinkBlock)block {
    [GRichTextAttributedLabelURL setCustomDetectMethod:block];
}


@end
