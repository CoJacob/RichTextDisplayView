
//
//  GRichImageItem.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/20.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichImageItem.h"
#import <CoreGraphics/CoreGraphics.h>

@interface GRichImageItem ()

@property (nonatomic, copy)   NSString *src;
@property (nonatomic, assign) CGFloat  height;
@property (nonatomic, assign) CGFloat  width;

@end

@implementation GRichImageItem

- (instancetype)initWithContent:(id)content width: (CGFloat )width {
    self = [super init];
    if (self) {
        NSDictionary *imgDict          = [content valueForKey:@"img"];
        NSDictionary *imageContentDict = [[imgDict allValues] firstObject];
        CGFloat originWidth            = [[imageContentDict valueForKey:@"data-wscnw"] floatValue];
        CGFloat originHeight           = [[imageContentDict valueForKey:@"data-wscnh"] floatValue];
        if (originWidth == 0)
        {
            originWidth = 1;
        }
        if (originWidth < width) {
            self.width = originWidth;
            self.height = originHeight;
        }else {
            self.height = (width * originHeight) / originWidth;
            self.width  = width;
        }
        if ([[imageContentDict allKeys] containsObject:@"src"])
        {
            self.src = [imageContentDict valueForKey:@"src"];
        }else {
            self.src = [imageContentDict valueForKey:@"data-mce-src"];
        }
    }
    return self;
}

@end
