//
//  YLFixLineLeadView.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/6.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLFixLineLeadView.h"
#import <CoreText/CoreText.h>

const CGFloat kGlobalLineLeading = 10.0;

@interface YLFixLineLeadView()

@property (nonatomic ,assign) CGFloat textHeight;

@end

@implementation YLFixLineLeadView

#pragma mark - 计算高度
+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont
{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:aText];
    // 设置全局样式
    [self addGlobalAttributeWithContent:content font:aFont];
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    // 粗略高度
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, aText.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    // 10这个值是随便给的，为了高度足够
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, aWidth, suggestSize.height*10));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, aText.length), pathRef, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    CGFloat ascent = 0;
    CGFloat descent = 0;
    CGFloat leading = 0;
    CGFloat totalHeight = 0;
    
    for (CFIndex i = 0; i < lineCount; i++) {
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, i);
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &leading);
        NSLog(@"ascent = %f---descent = %f---leading = %f",ascent,descent,leading);
        totalHeight += ascent + descent + kGlobalLineLeading;//行间距
    }
    
    NSLog(@"totalHeight = %f",totalHeight);
    return totalHeight;
}

#pragma mark - 工具方法
#pragma mark 给字符串添加全局属性，比如行距，字体大小，默认颜色
+ (void)addGlobalAttributeWithContent:(NSMutableAttributedString *)aContent font:(UIFont *)aFont
{
    // 段落的折行、行间距
    const CFIndex kNumberOfSetting = 2;
    CTLineBreakMode breakModel =  kCTLineBreakByWordWrapping;
    CGFloat lineLeading = kGlobalLineLeading;
    CTParagraphStyleSetting theSettings[kNumberOfSetting] = {
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&breakModel},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineLeading}
    };

    CTParagraphStyleRef paragraphStryeRef = CTParagraphStyleCreate(theSettings, kNumberOfSetting);
    [aContent addAttribute:NSParagraphStyleAttributeName value:(__bridge id)paragraphStryeRef range:NSMakeRange(0, aContent.length)];
    
    // 字体大小
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL);
    [aContent addAttribute:NSFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, aContent.length)];
    
    // 字体颜色
    [aContent addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, aContent.length)];
    
    // 内存管理
    CFRelease(paragraphStryeRef);
    CFRelease(fontRef);
}

// 一行一行绘制，未调整行高，行高不固定
- (void)drawRectWithLineByLine
{
    NSMutableAttributedString *attrSting = [[NSMutableAttributedString alloc] initWithString:self.text];
    // 设置样式
    [[self class] addGlobalAttributeWithContent:attrSting font:self.font];
    
    // 获取高度
    self.textHeight = [[self class] textHeightWithText:self.text width:CGRectGetWidth(self.bounds) font:self.font];
    
    // 创建绘制区域
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight));
    
    // 创建CTFramesetterRef
    CTFramesetterRef setterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrSting);
    
    // 创建CTFrameRef
    CTFrameRef frameRef = CTFramesetterCreateFrame(setterRef, CFRangeMake(0, attrSting.length), pathRef, NULL);
    
    // 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 反转坐标系
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.textHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // 一行一行绘制
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    
    // 把CTFrameRef里每一行的初始坐标写到数组里，注意coretext的坐标是在左下角为原点
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lineCount; i++) {
        CGPoint point = lineOrigins[i];
        NSLog(@"point.x = %f, point.y = %f",point.x,point.y);
    }
    
    NSLog(@"font.ascender = %f,descender = %f,lineHeight = %f,leading = %f",self.font.ascender,self.font.descender,self.font.lineHeight,self.font.leading);
    CGFloat frmaeY = 0;
    for (CFIndex i = 0; i < lineCount; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat lineAscent;//上行
        CGFloat lineDescent;//下行
        CGFloat lineLeading;//行间距
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        NSLog(@"lineAscent = %f",lineAscent);
        NSLog(@"lineDescent = %f",lineDescent);
        NSLog(@"lineLeading = %f",lineLeading);
        
        CGPoint lineOrigin = lineOrigins[i];
        NSLog(@"i = %ld, lineOrigin = %@",i,NSStringFromCGPoint(lineOrigin));

        // 微调Y值，需要注意的是CoreText的Y值是在baseLine处，而不是下方的descent。
        // lineDescent为正数，self.font.descender为负数
        if (i > 0) {
            // 第二行之后的需要计算
            frmaeY = frmaeY - kGlobalLineLeading - lineAscent;
            lineOrigin.y = frmaeY;
        } else {
            // 第一行可直接用
            frmaeY = lineOrigin.y;
        }
        
        // 调整坐标
        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, context);
        
        // 微调
        frmaeY = frmaeY - lineDescent;
    }
    
    CFRelease(pathRef);
    CFRelease(setterRef);
    CFRelease(frameRef);
}

- (void)drawRect:(CGRect)rect
{
    [self drawRectWithLineByLine];
}


@end
