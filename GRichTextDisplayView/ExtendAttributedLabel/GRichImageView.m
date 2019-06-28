//
//  GRichImageView.m
//  HPayablePostFramework
//
//  Created by Caoguo on 2018/6/7.
//  Copyright © 2018年 wallstreetcn. All rights reserved.
//

#import "GRichImageView.h"

@implementation GRichImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapHandle:)];
        [self addGestureRecognizer:imageTapGesture];
    }
    return self;
}

#pragma mark - Gesture

- (void)imageTapHandle: (UITapGestureRecognizer *)tapGesture {
    if (self.imageUrl.length) {
//        NSURL *url = [NSURL URLWithString:@"native://nativeapp/PhotoBrowse"];
//        [[MRouter sharedRouter] handleURL:url userInfo:@{@"imageURLs": @[self.imageUrl], @"imageURL":self.imageUrl}];
    }
}

@end
