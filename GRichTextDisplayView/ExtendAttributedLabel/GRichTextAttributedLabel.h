//
//  GRichTextAttributedLabel.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableAttributedString+RichText.h"
#import "GRichTextAttributedLabelDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface GRichTextAttributedLabel : UIView
@property (nonatomic,weak,nullable)     id<RichTextAttributedLabelDelegate> delegate;
@property (nonatomic,strong,nullable)    UIFont *font;                          //字体
@property (nonatomic,strong,nullable)    UIColor *textColor;                    //文字颜色
@property (nonatomic,strong,nullable)    UIColor *highlightColor;               //链接点击时背景高亮色
@property (nonatomic,strong,nullable)    UIColor *linkColor;                    //链接色
@property (nonatomic,strong,nullable)    UIColor *shadowColor;                  //阴影颜色
@property (nonatomic,assign)            CGSize  shadowOffset;                   //阴影offset
@property (nonatomic,assign)            CGFloat shadowBlur;                     //阴影半径
@property (nonatomic,assign)            BOOL    underLineForLink;               //链接是否带下划线
@property (nonatomic,assign)            BOOL    autoDetectLinks;                //自动检测
@property (nonatomic,assign)            NSInteger   numberOfLines;              //行数
@property (nonatomic,assign)            CTTextAlignment textAlignment;          //文字排版样式
@property (nonatomic,assign)            CTLineBreakMode lineBreakMode;          //LineBreakMode
@property (nonatomic,assign)            CGFloat lineSpacing;                    //行间距
@property (nonatomic,assign)            CGFloat paragraphSpacing;               //段间距
@property (nonatomic,copy,nullable)     NSString *text;                         //普通文本
@property (nonatomic,copy,nullable)     NSAttributedString *attributedText;     //属性文本
@property (nonatomic, assign)           BOOL     enableRetract;                 // 是否允许展开/收起
@property (nonatomic, assign)           BOOL     isRetractStatus;               // 是否为收起状态
@property (nonatomic, assign)           BOOL      hiddenExpandText;             // 隐藏'展开字符'
@property (nonatomic, assign)           BOOL      enableFoldAndExpand;

//添加文本
- (void)appendText:(NSString *)text;
- (void)appendAttributedText:(NSAttributedString *)attributedText;

//图片
- (void)appendImage:(UIImage *)image;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin;
- (void)appendImage:(UIImage *)image
            maxSize:(CGSize)maxSize
             margin:(UIEdgeInsets)margin
          alignment:(RichTextImageAlignment)alignment;

//UI控件
- (void)appendView:(UIView *)view;
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin;
- (void)appendView:(UIView *)view
            margin:(UIEdgeInsets)margin
         alignment:(RichTextImageAlignment)alignment;

// 添加颜色
- (void)addCustomTextFillColor: (UIColor *)fillColor
                      forRange:(NSRange)range;


//添加自定义链接
- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range;

- (void)addCustomLink:(id)linkData
             forRange:(NSRange)range
            linkColor:(UIColor *)color;

- (void)addCustomItalicForRange: (NSRange)range;


//大小
- (CGSize)sizeThatFits:(CGSize)size;

//设置全局的自定义Link检测Block(详见GRichTextAttributedLabelURL)
+ (void)setCustomDetectMethod:(nullable RichTextCustomDetectLinkBlock)block;

- (void)triggerFold;

@end

NS_ASSUME_NONNULL_END
