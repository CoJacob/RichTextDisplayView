//
//  GSimpleRichTextViewController.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "GSimpleRichTextViewController.h"
#import "GRichTextAttributedTextLayout.h"

@interface GSimpleRichTextViewController ()

@end

@implementation GSimpleRichTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"简单富文本";
    [self.scrollView addSubview:self.richTextAttributedLabel];
    [self _setUp];
}

- (void) _setUp {
    NSString *text = @"当下全球宏观形势日益严峻，贸易保护主义抬头，持续了半个多世纪的全球一体化进程面临挑战。面对复杂多变的局势，当固有的分析框架、交易模型失效时，我们更要搭建起完整、系统的经济世界观，以史鉴今，以扎实的基础理论架构指导中观分析框架与微观交易方法。本期大师课《大类资产框架手册》凝结了付总多年的积累，从宏观到微观，从世界经济矛盾到各大类资产分析方法，带你解读全球宏观投资逻辑。主讲人：付鹏【冲和投资董事，前银河期货首席宏观经济顾问】本期课程将：·分解全球宏观逻辑，颠覆你看待世界的方式；·梳理各大类资产，打破你分析框架的壁垒；·盘点经典交易案例，培养你的交易员视角。（下拉查看课程表）\n当下全球宏观形势日益严峻，贸易保护主义抬头，持续了半个多世纪的全球一体化进程面临挑战。面对复杂多变的局势，当固有的分析框架、交易模型失效时，我们更要搭建起完整、系统的经济世界观，以史鉴今，以扎实的基础理论架构指导中观分析框架与微观交易方法。本期大师课《大类资产框架手册》凝结了付总多年的积累，从宏观到微观，从世界经济矛盾到各大类资产分析方法，带你解读全球宏观投资逻辑。主讲人：付鹏【冲和投资董事，前银河期货首席宏观经济顾问】本期课程将：·分解全球宏观逻辑，颠覆你看待世界的方式；·梳理各大类资产，打破你分析框架的壁垒；·盘点经典交易案例，培养你的交易员视角。（下拉查看课程表)\n当下全球宏观形势日益严峻，贸易保护主义抬头，持续了半个多世纪的全球一体化进程面临挑战。面对复杂多变的局势，当固有的分析框架、交易模型失效时，我们更要搭建起完整、系统的经济世界观，以史鉴今，以扎实的基础理论架构指导中观分析框架与微观交易方法。本期大师课《大类资产框架手册》凝结了付总多年的积累，从宏观到微观，从世界经济矛盾到各大类资产分析方法，带你解读全球宏观投资逻辑。主讲人：付鹏【冲和投资董事，前银河期货首席宏观经济顾问】本期课程将：·分解全球宏观逻辑，颠覆你看待世界的方式；·梳理各大类资产，打破你分析框架的壁垒；·盘点经典交易案例，培养你的交易员视角。（下拉查看课程表\n......";
    self.richTextAttributedLabel.text = text;
    // italic斜体
    [self.richTextAttributedLabel addCustomItalicForRange:NSMakeRange(0, 12)];
    // href超链接
    [self.richTextAttributedLabel addCustomLink:@"https://baidu.com" forRange:NSMakeRange(13, 8)];
    [self.richTextAttributedLabel addCustomLink:@"https://apple.com" forRange:NSMakeRange(80, 10)];
    
    //字体背景色
    [self.richTextAttributedLabel addCustomTextFillColor:[UIColor cg_getColor:@"E62E4D"] forRange:NSMakeRange(25, 50)];
    
    [self resetLabelFrame];
}

- (void)resetLabelFrame {
    GRichTextAttributedTextContainer *container = [[GRichTextAttributedTextContainer alloc] init];
    container.width = CGRectGetWidth(self.view.frame) - 32.f;
    container.font = [UIFont systemFontOfSize:15.f];
    container.textAlignment = NSTextAlignmentLeft;
    container.lineSpacing = 3.f;
    GRichTextAttributedTextLayout *textLayout = [GRichTextAttributedTextLayout layoutWithContainer:container text:self.richTextAttributedLabel.text];
    CGRect labelRect = self.richTextAttributedLabel.frame;
    labelRect.size.height = textLayout.size.height;
    self.richTextAttributedLabel.frame = labelRect;
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame), textLayout.size.height + 16.f)];
}


@end
