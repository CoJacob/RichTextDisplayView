//
//  GRichTextAttributedTextLayout.h
//  GPayFramework
//
//  Created by Caoguo on 2018/9/21.
//  Copyright © 2018年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRichTextAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN
@class GRichTextAttributedTextContainer;

@interface GRichTextAttributedTextLayout : NSObject

@property (nonatomic, assign) CGSize size;

+ (GRichTextAttributedTextLayout *)layoutWithContainer:(GRichTextAttributedTextContainer *)container text:(NSString *)text;

+ (GRichTextAttributedTextLayout *)layoutWithContainer:(GRichTextAttributedTextContainer *)container attributedText:(NSAttributedString *)attributedText;

@end


@interface GRichTextAttributedTextContainer: NSObject

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
@property (nonatomic, assign)           CGFloat width;
@property (nonatomic, strong)           NSMutableArray  *attachments;

- (void)appendImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
