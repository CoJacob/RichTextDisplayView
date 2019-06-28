//
//  BaseDemoViewController.h
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRichTextDisplayView.h"
#import "GRichTextAttributedLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseDemoViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GRichTextDisplayView *richTextDisplayView;
@property (nonatomic, strong) GRichTextAttributedLabel *richTextAttributedLabel;

@end

NS_ASSUME_NONNULL_END
