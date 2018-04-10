//
//  YLFixLineHeightView.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/7.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLFixLineHeightView.h"
#import <CoreText/CoreText.h>

// 行距
const CGFloat kGlobalLineLeading = 5.0;

// 在15字体下，比值小于这个计算出来的高度会导致emoji显示不全
const CGFloat kPerLineRatio = 1.4;

@interface YLFixLineHeightView()

@property (nonatomic ,assign) CGFloat textHeight;

@end

@implementation YLFixLineHeightView

+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont
{
    // 可变属性字符串
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:aText];
    // 添加属性
    [self addGlobalAttributeWithContent:attrString font:aFont];
    // framesetterRef
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    // 粗略高度 不准 供参考
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, attrString.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    NSLog(@"suggestHeight = %f",suggestSize.height);
    // CGMutablePathRef
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, aWidth, suggestSize.height));
    // CTFrameRef
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attrString.length), pathRef, NULL);
    // 行数
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
     // 总高度 = 行数*每行的高度，其中每行的高度为指定的值，不同字体大小不一样
    CGFloat accurateHeight = lineCount * (aFont.pointSize * kPerLineRatio);
    
    CFRelease(frameRef);
    CFRelease(pathRef);
    
    return accurateHeight;
}

#pragma mark - 工具方法
#pragma mark 给字符串添加全局属性，比如行距，字体大小，默认颜色
+ (void)addGlobalAttributeWithContent:(NSMutableAttributedString *)aContent font:(UIFont *)aFont
{
    // 行间距
    CGFloat lineLeading = kGlobalLineLeading;
    // 段落样式设置数量
    const CFIndex kNumberOfSettings = 2;
    // 折行样式
    CTLineBreakMode lineBreakModel = kCTLineBreakByWordWrapping;
    // 段落样式
    CTParagraphStyleSetting settings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakModel},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineLeading}
    };
    CTParagraphStyleRef paragraphRef = CTParagraphStyleCreate(settings, kNumberOfSettings);
    
    // 设置段落样式
    [aContent addAttribute:NSParagraphStyleAttributeName value:(__bridge id)paragraphRef range:NSMakeRange(0, aContent.length)];
    
    // 设置字体 与 颜色
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL);
    [aContent addAttribute:NSFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, aContent.length)];
    [aContent addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, aContent.length)];
    
    // 内存管理
    CFRelease(paragraphRef);
    CFRelease(fontRef);
}

#pragma mark - 一行一行绘制，行高确定，行与行之间对齐
- (void)drawRectWithLineByLineAlignment
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.text];
    // 设置样式
    [[self class] addGlobalAttributeWithContent:attrString font:self.font];
    // 获取高度
    self.textHeight = [[self class] textHeightWithText:self.text width:CGRectGetWidth(self.bounds) font:self.font];
    
    // 创建绘制区域，path的高度对绘制有直接影响，如果高度不够，则计算出来的CTLine的数量会少一行或者少多行
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight*2));
    
    // CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    // CTFrameRef
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length), path, NULL);
    
    // 获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // 转换坐标系
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    // 此处用计算出来的高度
    CGContextTranslateCTM(contextRef, 0, self.textHeight);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 一行一行绘制
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];

    // 把ctFrame里每一行的初始坐标写到数组里，注意CoreText的坐标是左下角为原点
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lineCount; i++) {
        CGPoint point = lineOrigins[i];
        NSLog(@"point.y = %f",point.y);
    }
    
    NSLog(@"font.ascender = %f,descender = %f,lineHeight = %f,leading = %f",self.font.ascender,self.font.descender,self.font.lineHeight,self.font.leading);
    CGFloat frameY = 0;
    NSLog(@"self.textHeight = %f,lineHeight = %f",self.textHeight,self.font.pointSize * kPerLineRatio);
    
    for (CFIndex i = 0; i < lineCount; i++){
        // 遍历每一行CTLine
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading; // 行距
        // 该函数除了会设置好ascent,descent,leading之外，还会返回这行的宽度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        NSLog(@"lineAscent = %f",lineAscent);
        NSLog(@"lineDescent = %f",lineDescent);
        NSLog(@"lineLeading = %f",lineLeading);
        
        
        CGPoint lineOrigin = lineOrigins[i];
        NSLog(@"i = %ld, lineOrigin = %@",i,NSStringFromCGPoint(lineOrigin));
        
        // 微调Y值，需要注意的是CoreText的Y值是在baseLine处，而不是下方的descent。
        CGFloat lineHeight = self.font.pointSize * kPerLineRatio;
        frameY = self.textHeight - (i + 1)*lineHeight - self.font.descender;
        NSLog(@"frameY = %f",frameY);
        lineOrigin.y = frameY;
        // 调整坐标
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, contextRef);
    }
    
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(ctFrame);
}

- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLineByLineAlignment];
}


@end


