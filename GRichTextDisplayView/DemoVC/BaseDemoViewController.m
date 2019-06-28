//
//  BaseDemoViewController.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "BaseDemoViewController.h"

@interface BaseDemoViewController ()

@end

@implementation BaseDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kCG_Device_IPhoneXSeries ? 88 : 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 83.f)];
    }
    return _scrollView;
}

- (GRichTextDisplayView *)richTextDisplayView {
    if (!_richTextDisplayView) {
        _richTextDisplayView = [[GRichTextDisplayView alloc] initWithFrame:CGRectMake(16, 16, CGRectGetWidth(self.scrollView.frame), 0)];
        _richTextDisplayView.richTextFont = [UIFont systemFontOfSize:15.f];
    }
    return _richTextDisplayView;
}

- (GRichTextAttributedLabel *)richTextAttributedLabel {
    if (!_richTextAttributedLabel) {
        _richTextAttributedLabel = [[GRichTextAttributedLabel alloc] initWithFrame:CGRectMake(16, 16, CGRectGetWidth(self.scrollView.frame) - 32.f, 0)];
        _richTextAttributedLabel.font = [UIFont systemFontOfSize:15.f];
        _richTextAttributedLabel.lineSpacing = 2.f;
        _richTextAttributedLabel.textColor = [UIColor cg_getColor:@"333333"];
    }
    return _richTextAttributedLabel;
}

@end
