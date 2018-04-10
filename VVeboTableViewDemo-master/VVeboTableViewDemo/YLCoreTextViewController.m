//
//  YLCoreTextViewController.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/2.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLCoreTextViewController.h"
#import "YLCoreTextView.h"
#import "YLFixLineLeadView.h"
#import "YLFixLineHeightView.h"
#import "YLCoreTextTapView.h"
#import "YLCoreTextImageView.h"

@interface YLCoreTextViewController ()

@property (nonatomic, strong) YLCoreTextView *redView;
@property (nonatomic, strong) YLFixLineLeadView *fixLineView;
@property (nonatomic, strong) YLFixLineHeightView *fixLineHeightView;
@property (nonatomic, strong) YLCoreTextTapView *tapView;
@property (nonatomic, strong) YLCoreTextImageView *textImageView;

@end

@implementation YLCoreTextViewController

- (YLCoreTextView *)redView{
    if (!_redView) {
        _redView = [[YLCoreTextView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200)];
        _redView.backgroundColor = [UIColor whiteColor];
    }
    return _redView;
}

- (YLFixLineLeadView *)fixLineView{
    if (!_fixLineView) {
        NSString *string = @"门梁真可怕 当中英文混合之后，🐶🐶🐶🐶🐶🐶会出现行高不统一的情况，现在在绘制的时候根据字体的descender来偏移绘制，对齐baseline。🐱🐱🐱🐱🐱同时点击链接的时候会调用drawRect: 造成绘制异常，所以将setNeedsDisplay注释，如需刷新，请手动调用。带上emoji以供测试🐥🐥🐥🐥🐥";
        UIFont *font = [UIFont systemFontOfSize:17];
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = [YLFixLineLeadView textHeightWithText:string width:width font:font];
        
        _fixLineView = [[YLFixLineLeadView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, height)];
        _fixLineView.backgroundColor = [UIColor redColor];
        _fixLineView.text = string;
        _fixLineView.font = font;
    }
    return _fixLineView;
}

- (YLFixLineHeightView *)fixLineHeightView{
    if (!_fixLineHeightView) {
        NSString *string = @"门梁真可怕 当中英文混合之后，🐶🐶🐶🐶🐶🐶会出现行高不统一的情况，现在在绘制的时候根据字体的descender来偏移绘制，对齐baseline。🐱🐱🐱🐱🐱同时点击链接的时候会调用drawRect: 造成绘制异常，所以将setNeedsDisplay注释，如需刷新，请手动调用。带上emoji以供测试🐥🐥🐥🐥🐥";
        UIFont *font = [UIFont systemFontOfSize:17];
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = [YLFixLineHeightView textHeightWithText:string width:width font:font];
        
        _fixLineHeightView = [[YLFixLineHeightView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, height)];
        _fixLineHeightView.backgroundColor = [UIColor redColor];
        _fixLineHeightView.text = string;
        _fixLineHeightView.font = font;
    }
    return _fixLineHeightView;
}

- (YLCoreTextTapView *)tapView{
    if (!_tapView) {
        NSString *string = @"门梁真@张三可怕当中英文混合之后，🐶🐶🐶🐶🐶🐶会出现行高不统一的情况，现在在绘制的时候根据字体的descender来183偏移绘制，对齐baseline。🐱🐱🐱🐱🐱同时点击10085链接的时候会10086调用drawRect: 造成绘@syl制异常，所以将setNeedsDisplay注释，如@李明需刷新，请手动调用。带上emoji以供1578测试🐥🐥🐥🐥🐥";
        UIFont *font = [UIFont systemFontOfSize:17];
        CGFloat width = self.view.bounds.size.width;
        CGFloat height = [YLCoreTextTapView textHeightWithText:string width:width font:font];
        
        _tapView = [[YLCoreTextTapView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, height)];
        _tapView.backgroundColor = [UIColor redColor];
        _tapView.text = string;
        _tapView.font = font;
    }
    return _tapView;
}

- (YLCoreTextImageView *)textImageView{
    if (!_textImageView) {
//        NSString *string = @"门梁真@张三可怕当中英文混合之后，🐶🐶🐶🐶🐶🐶会出现行高不统一的情况，现在在绘制的时候根据字体的descender来183偏移绘制，对齐baseline。🐱🐱🐱🐱🐱同时点击10085链接的时候会10086调用drawRect: 造成绘@syl制异常，所以将setNeedsDisplay注释，如@李明需刷新，请手动调用。带上emoji以供1578测试🐥🐥🐥🐥🐥";
//        UIFont *font = [UIFont systemFontOfSize:17];
//        CGFloat width = self.view.bounds.size.width;
//        CGFloat height = [YLCoreTextTapView textHeightWithText:string width:width font:font];
        
        _textImageView = [[YLCoreTextImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 450)];
        _textImageView.backgroundColor = [UIColor whiteColor];
//        _textImageView.text = string;
//        _textImageView.font = font;
    }
    return _textImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreText";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //[self.view addSubview:self.redView];
    
    //[self.view addSubview:self.fixLineView];
    
    //[self.view addSubview:self.fixLineHeightView];
    
    //[self.view addSubview:self.tapView];

    [self.view addSubview:self.textImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
