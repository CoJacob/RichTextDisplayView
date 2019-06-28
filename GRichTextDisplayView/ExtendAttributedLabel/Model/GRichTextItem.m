//
//  GRichTextItem.m
//  HPayablePostFramework
//
//  Created by Namegold on 2017/7/19.
//  Copyright © 2017年 wallstreetcn. All rights reserved.
//

#import "GRichTextItem.h"

@interface GRichTextItem ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, copy)   NSString           *string;
@property (nonatomic, strong) NSMutableArray     *hrefRanges;
@property (nonatomic, strong) NSMutableArray     *boldRanges;
@property (nonatomic, strong) NSDictionary       *hrefDict;
@property (nonatomic, strong) NSArray            *italicArray;
@property (nonatomic, strong) NSDictionary       *italicDict;

@end

@implementation GRichTextItem

- (instancetype)initWithContent: (id )content fontSize: (CGFloat )fontSize {
    self = [super init];
    if (self) {
        self.string = [content valueForKey:@"string"];
        self.attributedString = [self arrtibutedStringWithText:self.string fontSize:fontSize];
        if ([[content allKeys] containsObject:@"strong"] ) {
            NSArray *boldArray = [content valueForKey:@"strong"];
            [boldArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSValue *boldValue = (NSValue *)obj;
                NSRange boldRange  = [boldValue rangeValue];
                if ((boldRange.length + boldRange.location) > [self.attributedString string].length) {
                    return ;
                }
                if ((boldRange.location) > [self.attributedString string].length) {
                    return ;
                }
                [self.attributedString addAttribute:NSFontAttributeName
                                              value:[UIFont systemFontOfSize:fontSize]
                                              range:boldRange];
            }];
        }
        if ([[content allKeys] containsObject:@"italic"]) {
            NSArray *italicArray = [content valueForKey:@"italic"];
            if (italicArray.count) {
                self.italicArray = italicArray;
            }
        }
        
        if ([[content allKeys] containsObject:@"href"] && [[content valueForKey:@"href"] allKeys].count) {
            self.hrefDict = [content valueForKey:@"href"];
        }
    }
    return self;
}

#pragma mark  - Getter

- (NSMutableArray *)hrefRanges {
    if (!_hrefRanges) {
        _hrefRanges = [NSMutableArray array];
    }
    return _hrefRanges;
}

- (NSMutableArray *)boldRanges {
    if (!_boldRanges) {
        _boldRanges = [NSMutableArray array];
    }
    return _boldRanges;
}

#pragma mark  - Private

- (NSMutableAttributedString *)arrtibutedStringWithText: (NSString *)text fontSize: (CGFloat )fontSize {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                                                                                          NSForegroundColorAttributeName:[UIColor colorWithRed:(51/255.f) green:(51/255.f) blue:(51/255.f) alpha:1]}]];
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}

@end
