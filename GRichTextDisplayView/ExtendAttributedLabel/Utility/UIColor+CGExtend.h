//
//  UIColor+CGExtend.h
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CGExtend)


+ (id)cg_getColor:(NSString *) hexColor;
+ (id)cg_getColor:(NSString *) hexColor alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
