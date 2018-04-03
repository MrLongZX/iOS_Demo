//
//  StudyViewController.m
//  VVeboTableViewDemo
//
//  Created by 苏友龙 on 2018/4/1.
//  Copyright © 2018年 Johnil. All rights reserved.
//

#import "StudyViewController.h"
#import "UIScreen+Additions.h"
#import "NSString+Additions.h"
#import "StudyTableViewCell.h"

static NSString *identifier = @"StudyTableViewCell";

@interface StudyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *table;

@end

@implementation StudyViewController
{
    NSMutableArray *datas;
}

- (UITableView *)table{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen screenWidth], [UIScreen screenHeight]) style:UITableViewStylePlain];
        _table.dataSource = self;
        _table.delegate = self;
        [_table registerClass:[StudyTableViewCell class] forCellReuseIdentifier:identifier];
        [self.view addSubview:_table];
    }
    return _table;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"学习测试";
    self.view.backgroundColor = [UIColor whiteColor];
    
    datas = [[NSMutableArray alloc] init];
    
    [self loadData];
    [self.table reloadData];
}

#pragma mark - tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}

- (void)drawCell:(StudyTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell clear];
    NSDictionary *data = [datas objectAtIndex:indexPath.row];
    cell.data = data;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StudyTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [self drawCell:cell withIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = datas[indexPath.row];
    return [dic[@"height"] integerValue];
    //NSLog(@"row:%ld, height:%ld",indexPath.row, [dic[@"height"] integerValue]);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)loadData
{
    NSArray *temp = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    for (NSDictionary *dict in temp) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        NSDictionary *retweet = [dict valueForKey:@"retweeted_status"];
        if (retweet) {
            data[@"text"] = [NSString stringWithFormat:@"%@ %@",dict[@"text"],retweet[@"text"]];
        } else {
            data[@"text"] = dict[@"text"];
        }
        
        float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
        CGSize size = [data[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_SUBCONTENT) lineSpace:5];
        NSInteger sizeHeight = (size.height+.5);
        data[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_BIG, width, sizeHeight)];
        sizeHeight += SIZE_GAP_BIG * 2;
        data[@"height"] = [NSString stringWithFormat:@"%ld",sizeHeight];
        [datas addObject:data];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
