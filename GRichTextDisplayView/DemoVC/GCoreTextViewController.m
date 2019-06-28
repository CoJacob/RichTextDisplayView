//
//  GCoreTextViewController.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "GCoreTextViewController.h"

@interface GCoreTextViewController ()

@end

@implementation GCoreTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图文混排";
    [self.scrollView addSubview:self.richTextAttributedLabel];
    [self _setUp];
}

- (void) _setUp {
    NSString *text = @"当下全球宏观形势日益严峻，贸易保护主义抬头，持续了半个多世纪的全球一体化进程面临挑战。面对复杂多变的局势，当固有的分析框架、交易模型失效时，我们更要搭建起完整、系统的经济世界观，以史鉴今，以扎实的基础理论架构指导中观分析框架与微观交易方法。本期大师课《大类资产框架手册》凝结了付总多年的积累，从宏观到微观，从世界经济矛盾到各大类资产分析方法，带你解读全球宏观投资逻辑。主讲人：付鹏【冲和投资董事，前银河期货首席宏观经济顾问】本期课程将：";
    self.richTextAttributedLabel.text = text;
    // italic斜体
    [self.richTextAttributedLabel addCustomItalicForRange:NSMakeRange(0, 12)];
    // href超链接
    [self.richTextAttributedLabel addCustomLink:@"https://baidu.com" forRange:NSMakeRange(13, 8) linkColor:[UIColor cg_getColor:@"1478f0"]];
    [self.richTextAttributedLabel addCustomLink:@"https://apple.com" forRange:NSMakeRange(80, 10) linkColor:[UIColor cg_getColor:@"E62E4D"]];
    
    //字体背景色
    [self.richTextAttributedLabel addCustomTextFillColor:[UIColor cg_getColor:@"E62E4D"] forRange:NSMakeRange(25, 50)];
    
    [self.richTextAttributedLabel appendImage:[UIImage imageNamed:@"coretext_img01"]];
    [self.richTextAttributedLabel appendText:@"更新内容如下:"];
    [self.richTextAttributedLabel appendImage:[UIImage imageNamed:@"coretext_img02"]];
    [self.richTextAttributedLabel appendText:@"未完待续..."];
    
    
    CGSize labelSize = [self.richTextAttributedLabel sizeThatFits:CGSizeMake(self.richTextAttributedLabel.frame.size.width, CGFLOAT_MAX)];
    CGRect rect = self.richTextAttributedLabel.frame;
    rect.size.height = labelSize.height;
    self.richTextAttributedLabel.frame = rect;
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), rect.size.height + 16.f)];
}


@end
