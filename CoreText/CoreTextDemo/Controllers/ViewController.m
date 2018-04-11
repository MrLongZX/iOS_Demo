//
//  ViewController.m
//  CoreTextDemo
//
//  Created by TangQiao on 13-12-3.
//  Copyright (c) 2013年 TangQiao. All rights reserved.
//

#import "ViewController.h"
#import "CTDisplayView.h"
#import "CTFrameParser.h"
#import "CTFrameParserConfig.h"
#import "ImageViewController.h"
#import "WebContentViewController.h"
#import "CoreTextLinkData.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet CTDisplayView *ctView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUserInterface];
    [self setupNotifications];
}

- (void)setupUserInterface {
    // 配置字体、段落参数
    CTFrameParserConfig *config = [[CTFrameParserConfig alloc] init];
    config.width = self.ctView.width;
    // 获取模板数据
    NSString *path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    // 创建CoreTextData
    CoreTextData *data = [CTFrameParser parseTemplateFile:path config:config];
    // 设置ctView参数
    self.ctView.data = data;
    self.ctView.height = data.height;
    self.ctView.backgroundColor = [UIColor whiteColor];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePressed:)
                                                 name:CTDisplayViewImagePressedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linkPressed:)
                                                 name:CTDisplayViewLinkPressedNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)imagePressed:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    CoreTextImageData *imageData = userInfo[@"imageData"];
    
    ImageViewController *vc = [[ImageViewController alloc] init];
    vc.image = [UIImage imageNamed:imageData.name];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)linkPressed:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    CoreTextLinkData *linkData = userInfo[@"linkData"];
    
    WebContentViewController *vc = [[WebContentViewController alloc] init];
    vc.urlTitle = linkData.title;
    vc.url = linkData.url;
    [self presentViewController:vc animated:YES completion:nil];
}
@end
