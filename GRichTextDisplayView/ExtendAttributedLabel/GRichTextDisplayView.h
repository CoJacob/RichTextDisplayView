//
//  GRichTextDisplayView.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRichTextDisplayView : UIView

@property (nonatomic, copy)     NSString  *htmlString;          // 富文本内容
@property (nonatomic, strong)   UIFont    *richTextFont;        // 字体
@property (nonatomic, assign)   NSInteger retractNumberOfLine;  // 展开/收起的行数
@property (nonatomic, assign)   BOOL      isRetractStatus;      // 是否为收起状态
@property (nonatomic, assign)   BOOL      hiddenExpandText;     // 隐藏'展开'字符
@property (nonatomic, assign)   BOOL      enableImgSeamlessSititching; // 是否支持图片无缝拼接
@property (nonatomic, copy)     void(^retratHandle)(void);

/**
 绘制一段html文本
 
 @param htmlText htm文本
 */
- (void)displayContentWithHtmlText: (NSString *)htmlText;


/**
 要显示的富文本的总高度
 
 @return richTextViewFrameHeight
 */
- (CGFloat )contentHeight;


@end
