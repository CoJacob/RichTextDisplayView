//
//  GHtmlTextViewController.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "GHtmlTextViewController.h"
#import "GRichTextDisplayViewLayout.h"

@interface GHtmlTextViewController ()

@end

@implementation GHtmlTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Html标签解析显示";
    [self.scrollView addSubview:self.richTextDisplayView];
    [self _setUp];
}

- (void) _setUp {
    self.richTextDisplayView.enableImgSeamlessSititching = YES;
    NSString *htmlText = @"<p>实物简介:</p><p><img class=\"wscnph\" src=\"https://wpimg.wallstcn.com/c2c10c66-b462-451e-8f1c-7df1a06b12cb.jpg\" data-wscntype=\"image\" data-wscnh=\"3646\" data-wscnw=\"1080\" /><img class=\"wscnph\" src=\"https://wpimg.wallstcn.com/bf918472-500e-4013-8c52-d6b63021540a.jpg\" data-wscntype=\"image\" data-wscnh=\"600\" data-wscnw=\"1080\" data-mce-src=\"https://wpimg.wallstcn.com/bf918472-500e-4013-8c52-d6b63021540a.jpg\"/></p>";
     CGFloat height = [GRichTextDisplayViewLayout heightForDrawHtmlText:htmlText viewWidth:CGRectGetWidth(self.richTextDisplayView.frame) font:[UIFont systemFontOfSize:15.f]];
    [self.richTextDisplayView displayContentWithHtmlText:htmlText];
    CGRect rect = self.richTextDisplayView.frame;
    rect.size.height = height;
    self.richTextDisplayView.frame = rect;
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), height + 16.f)];
}



@end
