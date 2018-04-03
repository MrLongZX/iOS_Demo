//
//  YLCoreTextView.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/2.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLCoreTextView.h"
#import <CoreText/CoreText.h>

@implementation YLCoreTextView

#pragma mark - CoreText 学习一
/*
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // 步骤1：得到当前用于绘制画布的上下文，用于后续将内容绘制在画布上
    // 因为Core Text要配合Core Graphic 配合使用的，如Core Graphic一样，绘图的时候需要获得当前的上下文进行绘制
    CGContextRef context = UIGraphicsGetCurrentContext();

     // 步骤2：翻转当前的坐标系（因为对于底层绘制引擎来说，屏幕左下角为（0，0））
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 步骤3：创建NSAttributedString
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"iOS程序在启动时会创建一个主线程，而在一个线程只能执行一件事情，如果在主线程执行某些耗时操作，例如加载网络图片，下载资源文件等会阻塞主线程（导致界面卡死，无法交互），所以就需要使用多线程技术来避免这类情况。iOS中有三种多线程技术 NSThread，NSOperation，GCD，这三种技术是随着IOS发展引入的，抽象层次由低到高，使用也越来越简单。"];

    // 步骤4：根据NSAttributedString创建CTFramesetterRef
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);

    // 步骤5：创建绘制区域CGPathRef
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, self.bounds);
 
    //CGPathAddEllipseInRect(path, NULL, self.bounds);
    //[[UIColor redColor] set];
    //CGContextFillEllipseInRect(context, self.bounds);
 

    // 步骤6：根据CTFramesetterRef和CGPathRef创建CTFrame；
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attrString.length), path, NULL);

    // 步骤7：CTFrameDraw绘制
    CTFrameDraw(frame, context);

    // 步骤8.内存管理
    CFRelease(frame);
    CFRelease(path);
    CFRelease(frameSetter);
}
*/

#pragma mark - CoreText 学习二
/*
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 翻转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 创建NSAttributedString
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"在现实生活中，我们要不断内外兼修，几十载的人生旅途，看过这边风景，必然错过那边彩虹，有所得，必然有所失。有时，我们只有彻底做到拿得起，放得下，才能拥有一份成熟，才会活得更加充实、坦然、轻松和自由。"];
    
    // 设置部分颜色
    [attrString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor greenColor].CGColor range:NSMakeRange(10, 10)];
    
    // 设置部分文字
    CGFloat fontSize = 20;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attrString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(15, 10)];
    CFRelease(fontRef);
    
    // 设置行距等样式
    CGFloat lineSpace = 10;
    CGFloat lineSpaceMax = 20;
    CGFloat lineSpaceMin = 2;
    const CFIndex kNumberOfSettings = 3;
    
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpaceMax},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpaceMin}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    // 单个样式元素的形式
    //CTParagraphStyleSetting theSettings = {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace};
    //CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, 1);
    
    [attrString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attrString.length)];
    CFRelease(theParagraphRef);
    
    // 根据NSAttributedString 创建 CTFramesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    // 创建绘制区域CGPathRef
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectInset(self.bounds, 0, 20));
    
    // 根据CTFramesetterRef 和 CGPathRef 创建 CTFrameRef
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attrString length]), pathRef, NULL);
    
    // CTFrameDraw绘制
    CTFrameDraw(frameRef, context);
    
    // 内存管理
    CFRelease(frameRef);
    CFRelease(pathRef);
    CFRelease(framesetterRef);
}
*/

#pragma mark - CoreText 学习三 绘框
/*
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"iOS程序在启动时会创建一个主线程，而在一个线程只能执行一件事情，如果在主线程执行某些耗时操作，例如加载网络图片，下载资源文件等会阻塞主线程（导致界面卡死，无法交互），所以就需要使用多线程技术来避免这类情况。iOS中有三种多线程技术 NSThread，NSOperation，GCD，这三种技术是随着IOS发展引入的，抽象层次由低到高，使用也越来越简单。"];
    //设置字体
    CGFloat fontSize = 18;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    [attrString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, attrString.length)];
    CFRelease(fontRef);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, self.bounds);
    
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attrString.length), pathRef, NULL);
    
    //获取frame中CTLineRef数组
    CFArrayRef lines = CTFrameGetLines(frameRef);
    //获取数组Lines中的个数
    CFIndex lineCount = CFArrayGetCount(lines);
    
    //获取基线原点
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    for (CFIndex i = 0; i < lineCount; i++ ) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
         //相对于每一行基线原点的偏移量和宽高（例如：{{1.2， -2.57227}, {208.025, 19.2523}}，就是相对于本身的基线原点向右偏移1.2个单位，向下偏移2.57227个单位，后面是宽高）
        CGRect lineBounds = CTLineGetImageBounds(line, context);
        NSLog(@"lineBounds = %@",NSStringFromCGRect(lineBounds));
        NSLog(@"point = %@",NSStringFromCGPoint(origins[i]));
        //每一行的起始点（相对于context）加上相对于本身基线原点的偏移量
        lineBounds.origin.x += origins[i].x;
        lineBounds.origin.y += origins[i].y;
        //填充
        CGContextSetLineWidth(context, 1.0);
        CGContextAddRect(context, lineBounds);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextStrokeRect(context, lineBounds);
    }
    
    CTFrameDraw(frameRef, context);
    
    CFRelease(frameRef);
    CFRelease(pathRef);
    CFRelease(framesetterRef);
}
*/

#pragma mark - CoreText 学习四 单行绘制
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"门梁真可怕 当中英文混合之后，🐶🐶🐶🐶🐶🐶会出现行高不统一的情况，现在在绘制的时候根据字体的descender来偏移绘制，对齐baseline。🐱🐱🐱🐱🐱同时点击链接的时候会调用drawRect: 造成绘制异常，所以将setNeedsDisplay注释，如需刷新，请手动调用。带上emoji以供测试🐥🐥🐥🐥🐥"];
    CTFontRef font = CTFontCreateWithName(CFSTR("Georgia"), 18, NULL);
    [attrString addAttribute:(id)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, attrString.length)];
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attrString.length), path, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    //获取基线原点
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), origins);
    
    for (CFIndex i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        //获取CTLine的上行高度，下行高度，行距
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        NSLog(@"lineAscent = %f",lineAscent);
        NSLog(@"lineDescent = %f",lineDescent);
        NSLog(@"lineLeading = %f",lineLeading);
        
        CGPoint lineOrigin = origins[i];
        NSLog(@"point = %@",NSStringFromCGPoint(lineOrigin));

        CGRect oldLineBounds = CTLineGetImageBounds(line, context);
        NSLog(@"lineBounds改动前：%@",NSStringFromCGRect(oldLineBounds));

        NSLog(@"y = %f  d = %f  fontD = %f",lineOrigin.y,lineDescent,CTFontGetDescent(font));

        NSLog(@"Position修改前%@",NSStringFromCGPoint(CGContextGetTextPosition(context)));
        //设置CoreText绘制前的坐标。设置基线位置
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y - lineDescent - CTFontGetDescent(font));
        NSLog(@"Position修改后%@",NSStringFromCGPoint(CGContextGetTextPosition(context)));

        CGRect lineBounds = CTLineGetImageBounds(line, context);
        NSLog(@"lineBounds改动后：%@",NSStringFromCGRect(lineBounds));

        //填充
        CGContextSetLineWidth(context, 1.0);
        CGContextAddRect(context, lineBounds);
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        CGContextStrokeRect(context, lineBounds);
        
        //绘制原点为左下角
        CTLineDraw(line, context);
    }
    //CTFrameDraw(frameRef, context);
    
    CFRelease(frameRef);
    CFRelease(framesetterRef);
    CFRelease(path);
}

@end




































