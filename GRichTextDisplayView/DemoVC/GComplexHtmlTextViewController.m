//
//  GComplexHtmlTextViewController.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "GComplexHtmlTextViewController.h"
#import "GRichTextDisplayViewLayout.h"

@interface GComplexHtmlTextViewController ()

@property (nonatomic, strong) UIButton  *shinkButton;
@property (nonatomic, copy)   NSString  *htmlText;
@property (nonatomic, assign) CGFloat   foldTextHeight;
@property (nonatomic, assign) CGFloat   unfoldTextHeight;

@end

@implementation GComplexHtmlTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"富文本(支持展开收起、屏幕旋转)";
    [self.scrollView addSubview:self.richTextDisplayView];
    [self.scrollView addSubview:self.shinkButton];
    {
        self.richTextDisplayView.retractNumberOfLine = 5;
        self.richTextDisplayView.isRetractStatus = YES;
        self.richTextDisplayView.enableFoldAndExpand = YES;
        __weak __typeof__(self) weakSelf = self;
        self.richTextDisplayView.retratHandle = ^{
            [weakSelf expandContentClick];
        };
    }
    [self _setUpTextData];
    [self _setUp];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = CGRectMake(0, kCG_Device_IPhoneXSeries ? 88 : 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 83.f);
    
    CGRect rect = self.richTextDisplayView.frame;
    rect.size.width = CGRectGetWidth(self.view.frame) - 32.f;
    self.richTextDisplayView.frame = rect;
    [self _setUp];
}

#pragma mark - Getter

-(UIButton *)shinkButton {
    if (!_shinkButton) {
        _shinkButton = [[UIButton alloc] init];
        [_shinkButton setTitle:@"收起" forState:UIControlStateNormal];
        [_shinkButton setTitleColor:[UIColor cg_getColor:@"1482f0"] forState:UIControlStateNormal];
        _shinkButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        CGSize size = [_shinkButton sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
        _shinkButton.frame = CGRectMake(15, 0, size.width + 10, 30);
        _shinkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_shinkButton addTarget:self action:@selector(shinkButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _shinkButton.hidden = YES;
    }
    return _shinkButton;
}

- (void) _setUpTextData {
    self.richTextDisplayView.enableImgSeamlessSititching = YES;
    self.htmlText = @"<p>Developer计划 Apple Developer Program  注册探索macOSiOSwatchOStvOSSafari 和 Web (英文)游戏开发 (英文)企业 (英文)教育 (英文)WWDC (英文)设计Human Interface Guidelines (英文)资源 (英文)视频 (英文)Apple 设计大奖 (英文)字体 (英文)辅助功能App 国际化配件设计开发XcodeSwiftSwift PlaygroundsTestFlight文档 (英文) 简体中文文档 视频 (英文) 下载 (英文) 分发 开发者帐户 App Store App Review Mac 软件 商务 App (英文) Safari 扩展 (英文) 营销资源 商标使用许可 (英文) 支持 文档 开发者论坛 (英文) 反馈 & 错误报告 (英文) 系统状态 (英文) 联系我们 帐户 (英文) 证书、标识符和描述文件 (英文) App Store Connect\n实物简介:</p><p><img class=\"wscnph\" src=\"https://wpimg.wallstcn.com/c2c10c66-b462-451e-8f1c-7df1a06b12cb.jpg\" data-wscntype=\"image\" data-wscnh=\"3646\" data-wscnw=\"1080\" /><img class=\"wscnph\" src=\"https://wpimg.wallstcn.com/bf918472-500e-4013-8c52-d6b63021540a.jpg\" data-wscntype=\"image\" data-wscnh=\"600\" data-wscnw=\"1080\" data-mce-src=\"https://wpimg.wallstcn.com/bf918472-500e-4013-8c52-d6b63021540a.jpg\"/></p>";
    self.foldTextHeight = [GRichTextDisplayViewLayout heightForDrawHtmlText:self.htmlText
                                                                    viewWidth:CGRectGetWidth(self.richTextDisplayView.frame)
                                                                         font:[UIFont systemFontOfSize:15.f]
                                                          retractNumberOfLine:5];
}

- (void) _setUp {
    
    [self.richTextDisplayView displayContentWithHtmlText:self.htmlText];
    CGRect rect = self.richTextDisplayView.frame;
    rect.size.height = self.richTextDisplayView.isRetractStatus ? self.foldTextHeight : self.unfoldTextHeight;
    self.richTextDisplayView.frame = rect;
    if (!self.richTextDisplayView.isRetractStatus) {
        CGRect rect = self.shinkButton.frame;
        rect.origin.y = CGRectGetMaxY(self.richTextDisplayView.frame);
        self.shinkButton.frame = rect;
    }
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), [self contentSizeHeight])];
}

- (CGFloat )contentSizeHeight {
    CGFloat contentHeight = 0;
    if (self.richTextDisplayView.isRetractStatus) {
        contentHeight = self.foldTextHeight + 10;
    } else {
        contentHeight = self.unfoldTextHeight + CGRectGetHeight(self.shinkButton.frame) + 10;
    }
    return contentHeight;
}

- (void)expandContentClick {
    self.unfoldTextHeight = CGRectGetHeight(self.richTextDisplayView.frame);
    CGFloat contentHeight = [self contentSizeHeight];
    if (self.richTextDisplayView.isRetractStatus) {
        self.shinkButton.hidden = YES;
    } else {
        self.shinkButton.hidden = NO;
        CGRect rect = self.shinkButton.frame;
        rect.origin.y = CGRectGetMaxY(self.richTextDisplayView.frame);
        self.shinkButton.frame = rect;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), contentHeight)];
    } completion:^(BOOL finished) {
        
    }];
    
    
}

#pragma mark - IBAction

- (void)shinkButtonClick: (UIButton *)button {
    [self.richTextDisplayView triggerFold];
}

- (BOOL)canAutoRotate {
    return YES;
}

@end
