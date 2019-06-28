//
//  GRichTextAttributedLabelDefines.h
//  HPayablePostFramework
//
//  Created by Namegold on 2017/9/29.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#ifndef GRichTextAttributedLabelDefines_h
#define GRichTextAttributedLabelDefines_h

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#import "UIColor+CGExtend.h"
#import "UIImage+GScaleZoom.h"

typedef NS_OPTIONS(NSUInteger, RichTextImageAlignment) {
    RichTextImageAlignmentTop,
    RichTextImageAlignmentCenter,
    RichTextImageAlignmentBottom
};

UIKIT_EXTERN NSString *  _Nullable const GTextGlyphTransformAttributeName;

@class GrichTextAttributedLabel;

@protocol RichTextAttributedLabelDelegate <NSObject>

@optional
- (void)richTextAttributedLabel:(GrichTextAttributedLabel *_Nullable)label
                  clickedOnLink:(id _Nullable )linkData;

- (void)richTextAttributedLabel:(GrichTextAttributedLabel *_Nullable)label
                  clickRetractButton:(BOOL )retract;

@end

//如果文本长度小于这个值,直接在UI线程做Link检测,否则都dispatch到共享线程
#define RichTextMinAsyncDetectLinkLength 50


typedef NSArray * _Nullable (^RichTextCustomDetectLinkBlock)(NSString * _Nullable text);


#endif /* GRichTextAttributedLabelDefines_h */
