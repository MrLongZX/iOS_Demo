//
//  YLCoreTextTapView.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/8.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLCoreTextTapView.h"
#import <CoreText/CoreText.h>

// 行距
const CGFloat kGlobalLineLeading = 5.0;
// 在15字体下，比值小于这个计算出来的高度会导致emoji显示不全
const CGFloat kPerLineRatio = 1.4;

#define kAtRegularExpression @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"
#define kNumberRegularExpression @"^\\d{n}$"

@interface YLCoreTextTapView()<UIGestureRecognizerDelegate>

@property(nonatomic,assign) CTFrameRef ctFrame;

// 目前点击的字符串的范围
@property(nonatomic,assign) NSRange pressRange;
// 文本高度
@property(nonatomic,assign) CGFloat textHeight;

@property (nonatomic, assign) CGFloat height;

@end

@implementation YLCoreTextTapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configSettings];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawRectWithCheckClick];
}

#pragma mark - 绘制
- (void)drawRectWithCheckClick{
    // 创建需要绘制的文字
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    // 设置行距等样式
    [[self class] addGlobalAttributeWithContent:attributed font:self.font];
    
    // 识别特定字符串并改变其颜色
    [self recognizeSpecialStringWithAttributed:attributed];
    
    // 加一个点击改变字符串颜色的效果
    if (self.pressRange.location != 0 && self.pressRange.length != 0){
        [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:self.pressRange];
    }
    
    self.textHeight = [[self class] textHeightWithText:self.text width:CGRectGetWidth(self.bounds) font:self.font];
    
    // 创建绘制区域，path的高度对绘制有直接影响，如果高度不够，则计算出来的CTLine的数量会少一行或者少多行
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.textHeight*2));
    
    // 根据NSAttributedString生成CTFramesetterRef
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributed.length), path, NULL);
    self.ctFrame = CFRetain(ctFrame);
    
    // 获取上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // 转换坐标系
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.textHeight); // 此处用计算出来的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    // 一行一行绘制
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    
    // 把ctFrame里每一行的初始坐标写到数组里，注意CoreText的坐标是左下角为原点
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    CGFloat frameY = 0;
    for (CFIndex i = 0; i < lineCount; i++){
        // 遍历每一行CTLine
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading; // 行距
        // 该函数除了会设置好ascent,descent,leading之外，还会返回这行的宽度
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CGPoint lineOrigin = lineOrigins[i];
        
        // 微调Y值，需要注意的是CoreText的Y值是在baseLine处，而不是下方的descent。
        CGFloat lineHeight = self.font.pointSize * kPerLineRatio;
        frameY = self.textHeight - (i + 1)*lineHeight - self.font.descender;
        lineOrigin.y = frameY;
        // 调整坐标
        CGContextSetTextPosition(contextRef, lineOrigin.x, lineOrigin.y);
        CTLineDraw(line, contextRef);
    }
    CFRelease(path);
    CFRelease(framesetter);
    CFRelease(ctFrame);
}

- (void)configSettings
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.01;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
}

#pragma mark - 手势识别相关
- (void)longPress:(UIGestureRecognizer *)gesture
{
    // 改变字符串颜色并进行重绘
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.pressRange.length != 0 || self.pressRange.location != 0) {
            [self setNeedsDisplay];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.pressRange.location != 0 && self.pressRange.length != 0) {
            NSString *clickStr = [self.text substringWithRange:self.pressRange];
            NSLog(@"点击了：%@",clickStr);
            self.pressRange = NSMakeRange(0, 0);
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 点击处在特定字符串内才识别
    BOOL gestureShouldBegin = NO;
    // 点击的位置
    CGPoint location = [gestureRecognizer locationInView:self];
    // 单行高度
    CGFloat lineHeight = self.font.pointSize * kPerLineRatio;
    // 点击的行数
    int lineIndex = location.y/lineHeight;
    //  把点击的坐标转换为CoreText坐标系下
    CGPoint clickPoint = CGPointMake(location.x, self.height - location.y);
    
    CFArrayRef lines = CTFrameGetLines(self.ctFrame);
    if (lineIndex < CFArrayGetCount(lines)) {
        CTLineRef clickLine = CFArrayGetValueAtIndex(lines, lineIndex);
        // 点击出的字符串位于总字符串的index
        CFIndex strIndex = CTLineGetStringIndexForPosition(clickLine, clickPoint);
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.text];
        NSArray *checkResults = [self recognizeSpecialStringWithAttributed:attrString];
        for (NSValue *value in checkResults) {
            NSRange range = [value rangeValue];
            if (strIndex >= range.location && strIndex <= range.location + range.length) {
                self.pressRange = range;
                gestureShouldBegin = YES;
            }
        }
    }
    
    return gestureShouldBegin;
}

// 该方法可实现也可不实现，取决于应用场景
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // 避免应用在UITableViewCell上时，挡住拖动tableView的手势
        return YES;
    }
    return NO;
}

#pragma mark - 识别特定字符串并改其颜色，返回识别到的字符串所在的range
- (NSMutableArray *)recognizeSpecialStringWithAttributed:(NSMutableAttributedString *)attributed
{
    NSMutableArray *rangeArray = [NSMutableArray array];
    // 识别@人名
    // 创建正则表达式
    NSRegularExpression *atReguler = [NSRegularExpression regularExpressionWithPattern:kAtRegularExpression options:NSRegularExpressionCaseInsensitive error:nil];
    //返回一个数组，包含字符串中正则表达式的所有匹配项
    NSArray *atResults = [atReguler matchesInString:self.text options:NSMatchingWithTransparentBounds range:NSMakeRange(0, self.text.length)];
    // 修改匹配字符串颜色 并 把字符串位置放到数组中
    for (NSTextCheckingResult *checkResult in atResults) {
        if (attributed) {
            [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(checkResult.range.location, checkResult.range.length-1)];
        }
        [rangeArray addObject:[NSValue valueWithRange:checkResult.range]];
    }
    
    // 识别连续的数字
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:kNumberRegularExpression options:NSRegularExpressionCaseInsensitive |NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray *numberResult = [numberRegular matchesInString:self.text options:NSMatchingWithTransparentBounds range:NSMakeRange(0, self.text.length)];
    for (NSTextCheckingResult *checkResult in numberResult) {
        if (attributed) {
            [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(checkResult.range.location, checkResult.range.length-1)];
        }
        [rangeArray addObject:[NSValue valueWithRange:NSMakeRange(checkResult.range.location, checkResult.range.length-1)]];
    }
    return rangeArray;
}

#pragma mark - 工具方法
#pragma mark 给字符串添加全局属性，比如行距，字体大小，默认颜色
+ (void)addGlobalAttributeWithContent:(NSMutableAttributedString *)attributeString font:(UIFont *)aFont{
    // 设置文字
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", aFont.pointSize, NULL);
    [attributeString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, attributeString.length)];
    // 设置行距等样式
    CGFloat lineSpace = kGlobalLineLeading;
    CGFloat lineSpaceMax = 20;
    CGFloat lineSpaceMin = 2;
    const CFIndex kNumberOfSettings = 3;
    // 结构体数组
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpaceMax},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpaceMin}
    };
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    [attributeString addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge  id)theParagraphRef range:NSMakeRange(0, attributeString.length)];
    
    // 内存管理
    CFRelease(fontRef);
    CFRelease(theParagraphRef);
}


// 固定行高  高度 = 每行的固定高度 * 行数
+ (CGFloat)textHeightWithText:(NSString *)aText width:(CGFloat)aWidth font:(UIFont *)aFont
{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:aText];
    // 给字符串设置字体行距等样式
    [self addGlobalAttributeWithContent:content font:aFont];
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)content);
    // 粗略的高度，该高度不准，仅供参考
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, content.length), NULL, CGSizeMake(aWidth, MAXFLOAT), NULL);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, aWidth, suggestSize.height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, content.length), pathRef, NULL);
    
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CFIndex lineCount = CFArrayGetCount(lines);
    
    // 总高度 = 行数*每行的高度，其中每行的高度为指定的值，不同字体大小不一样
    CGFloat accurateHeight = lineCount * (aFont.pointSize * kPerLineRatio);
    CGFloat height = accurateHeight;
    
    CFRelease(pathRef);
    CFRelease(frameRef);
    
    return height;
}

@end
