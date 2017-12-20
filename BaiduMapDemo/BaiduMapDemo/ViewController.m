//
//  ViewController.m
//  BaiduMapDemo
//
//  Created by 苏友龙 on 2017/11/18.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "ViewController.h"
#import "YLCustomAnnotationViewVC.h"
#import "YLClusterController.h"

static NSString *identifier = @"identifier";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

/* table */
@property (nonatomic, strong) UITableView *styleTable;

/** dataArray */
@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation ViewController

- (UITableView *)styleTable{
    if (!_styleTable) {
        _styleTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _styleTable.delegate = self;
        _styleTable.dataSource = self;
        [_styleTable registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _styleTable;
}

- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = [NSArray arrayWithObjects:@"自定义大头针",@"点聚合", nil];
    }
    return _titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"百度地图Demo积累";
    [self.view addSubview:self.styleTable];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _titleArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        YLCustomAnnotationViewVC *annotation = [[YLCustomAnnotationViewVC alloc] init];
        [self.navigationController pushViewController:annotation animated:YES];
    } else if (indexPath.row == 1) {
        YLClusterController *cluster = [[YLClusterController alloc] init];
        [self.navigationController pushViewController:cluster animated:YES];
    } else if (indexPath.row == 2) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
