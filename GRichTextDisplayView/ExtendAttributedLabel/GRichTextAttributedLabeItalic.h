//
//  GRichTextAttributedLabeItalic.h
//  HPayablePostFramework
//
//  Created by Caoguo on 2018/5/17.
//  Copyright © 2018年 wallstreetcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GRichTextAttributedLabeItalic : NSObject

@property (nonatomic,assign)                NSRange range;
@property (nonatomic,strong,nullable)       UIColor *color;

+ (GRichTextAttributedLabeItalic *)italicWithRange:(NSRange)range
                                           color:(nullable UIColor *)color;

@end

NS_ASSUME_NONNULL_END
