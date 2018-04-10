//
//  YLCoreTextImageView.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/9.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "YLCoreTextImageView.h"
#import <CoreText/CoreText.h>
#import "SDWebImageManager.h"

@interface YLCoreTextImageView()

/** 网络图片 */
@property (nonatomic, strong) UIImage *image;

@end

@implementation YLCoreTextImageView


#pragma mark - 图片处理代理
void RunDelegateDeallocCallback(void *refCon)
{
    NSLog(@"RunDelegate Dealloc");
}

CGFloat RunDelegateGetfAscentCallback(void *refCon)
{
    NSString *imageName = (__bridge NSString *)refCon;
    if ([imageName isKindOfClass:[NSString class]]) {
        // 对应本地图片
        return [UIImage imageNamed:imageName].size.height;
    }
    // 对应网络图片
    return [[(__bridge NSDictionary *)refCon objectForKey:@"height" ] floatValue];
}

CGFloat RunDelegateGetDescentCallback(void *refCon)
{
    return 0;
}

CGFloat RunDelegateGetfWidthCallback(void *refCon)
{
    NSString *imageName = (__bridge NSString *)refCon;
    if ([imageName isKindOfClass:[NSString class]]) {
        // 对应本地图片
        return [UIImage imageNamed:imageName].size.width;
    }
    // 对应网络图片
    return [[(__bridge NSDictionary *)refCon objectForKey:@"width" ] floatValue];
}

// 下载图片
- (void)downLoadImageWithURL:(NSURL *)url
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SDWebImageOptions options = SDWebImageRetryFailed | SDWebImageHandleCookies |SDWebImageContinueInBackground;
        options = SDWebImageRetryFailed | SDWebImageContinueInBackground;
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            weakSelf.image = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.image) {
                    [weakSelf setNeedsDisplay];
                }
            });
        }];
    });
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSString *title = @"在现实生活中，我们要不断内外兼修，几十载的人生旅途，看过这边风景，必然错过那边彩虹，有所得，必然有所失。有时，我们只有彻底做到拿得起，放得下，才能拥有一份成熟，才会活得更加充实、坦然、轻松和自由。";

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // [a,b,c,d,tx,ty]
    NSLog(@"转换前的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));
    
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, self.bounds.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    NSLog(@"转换后的坐标：%@",NSStringFromCGAffineTransform(CGContextGetCTM(contextRef)));

    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:title];
    
    // 字体大小
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 5)];
    // 字体颜色
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(3, 10)];
    [attributed addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor greenColor].CGColor range:NSMakeRange(0, 2)];
    // 设置行距等样式
    CGFloat lineSpace = 10;
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
    [attributed addAttribute:NSParagraphStyleAttributeName value:(__bridge id)theParagraphRef range:NSMakeRange(0, attributed.length)];
    CFRelease(theParagraphRef);
    
    // 插入图片部分
    // 为图片设置CTRunDelegate,delegate决定留给图片的空间大小
    NSString *weicaiImageName = @"yun.jpg";
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = RunDelegateDeallocCallback;
    imageCallbacks.getAscent = RunDelegateGetfAscentCallback;
    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
    imageCallbacks.getWidth = RunDelegateGetfWidthCallback;
    
    // 本地图片
    // 设置CTRun的代理
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void*)(weicaiImageName));
    // 空格用于给图片留位置
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];
    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
    CFRelease(runDelegate);
    [imageAttributedString addAttribute:@"imageName" value:weicaiImageName range:NSMakeRange(0, 1)];
    // 在index处插入图片，可插入多张
    [attributed insertAttributedString:imageAttributedString atIndex:5];
    
    
    // 网络图片 需要使用0xFFFC作为占位符
    // 图片信息字典
    NSString *picURL = @"http://n.sinaimg.cn/translate/20170726/Zjd3-fyiiahz2863063.jpg";
    UIImage *pImage = [UIImage imageNamed:@"123.jpg"];
    // 宽高跟具体图片相关
    NSDictionary *imgInfoDic = @{@"width":@(166),@"height":@(180)};
    // 设置CTRun的代理
    CTRunDelegateRef delegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)imgInfoDic);
    // 使用0xFFFC作为空白占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    // 将创建的空白AttributedString插入进当前的attrString中，位置可以随便指定，不能越界
    [attributed insertAttributedString:space atIndex:10];
    
    // 这个时候走绘制图片的代理方法
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributed);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, self.bounds);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, attributed.length), pathRef, NULL);
    
    // 绘制
    CTFrameDraw(frameRef, contextRef);
    
    // 处理绘制图片的逻辑
    CFArrayRef lines = CTFrameGetLines(frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    
    // 把ctFrame里每一行的初始坐标写到数组里
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    // 遍历CTRun找出图片所在的CTRun并进行绘制
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        // 遍历每一个CTRun
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            // 获取该行的初始坐标
            CGPoint lineOrigin = lineOrigins[i];
            // 获取当前的CTRun
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            NSString *imageNmae = [attributes objectForKey:@"imageName"];
            if ([imageNmae isKindOfClass:[NSString class]]) {
                // 绘制本地图片
                UIImage *image = [UIImage imageNamed:imageNmae];
                CGRect imageDrawRect;
                imageDrawRect.size = image.size;
                imageDrawRect.origin.x = runRect.origin.x;
                imageDrawRect.origin.y = lineOrigin.y;
                CGContextDrawImage(contextRef, imageDrawRect, image.CGImage);
            } else {
                imageNmae = nil;
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes objectForKey:(__bridge id)kCTRunDelegateAttributeName];
                if (!delegate) {
                    // 如果是非图片的CTRun则跳过
                    continue;
                }
                // 网络图片
                UIImage *image;
                if (!self.image) {
                    // 未下载完成 使用占位图
                    image = pImage;
                    [self downLoadImageWithURL:[NSURL URLWithString:picURL]];
                } else {
                    image = self.image;
                }
                
                // 绘制网络图片
                CGRect imageDrawRect;
                imageDrawRect.size = image.size;
                imageDrawRect.origin.x = runRect.origin.x;
                imageDrawRect.origin.y = lineOrigin.y;
                CGContextDrawImage(contextRef, imageDrawRect, image.CGImage);
            }
        }
        
    }
    //内存管理
    CFRelease(frameRef);
    CFRelease(pathRef);
    CFRelease(framesetterRef);
}


@end
