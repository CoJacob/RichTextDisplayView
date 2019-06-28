//
//  GRichTextAttributedLabelURL.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRichTextAttributedLabelDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface GRichTextAttributedLabelURL : NSObject
@property (nonatomic,strong)                id      linkData;
@property (nonatomic,assign)                NSRange range;
@property (nonatomic,strong,nullable)       UIColor *color;

+ (GRichTextAttributedLabelURL *)urlWithLinkData:(id)linkData
                                     range:(NSRange)range
                                     color:(nullable UIColor *)color;

+ (nullable NSArray *)detectLinks:(nullable NSString *)plainText;

+ (void)setCustomDetectMethod:(nullable RichTextCustomDetectLinkBlock)block;

@end

NS_ASSUME_NONNULL_END
