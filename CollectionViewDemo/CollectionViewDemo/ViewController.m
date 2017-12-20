//
//  ViewController.m
//  CollectionViewDemo
//
//  Created by 苏友龙 on 2017/12/17.
//  Copyright © 2017年 YL. All rights reserved.
//

#import "ViewController.h"
#import "OilDetailsCollectionViewCell.h"

#define myScreenWidth [UIScreen mainScreen].bounds.size.width
#define myScreenHeight [UIScreen mainScreen].bounds.size.height

static NSString *identifier = @"collectionIdentifier";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

/** 模拟数据 */
@property (nonatomic, strong) NSArray *array;

/** collectionView */
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        NSInteger space = 10;
        layout.itemSize = CGSizeMake((myScreenWidth-30-space*2)/3, 55);
        // Cell纵向间距
        layout.minimumLineSpacing = 10.0f;
        // Cell横向间距
        layout.minimumInteritemSpacing = 10.0f;
        // 定义整个CollectionViewCell与整个View的间距
        layout.sectionInset = UIEdgeInsetsMake(20, 15, 0, 15);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[OilDetailsCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        
        _collectionView.frame = CGRectMake(0, 100, myScreenWidth, 250);
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    _array = @[@"柴#0",@"汽#92",@"汽#95",@"柴国V",@"柴国V2",@"汽#94",];
    
    [self.view addSubview:self.collectionView];
}

#pragma mark --- UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OilDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.detailStr  = _array[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",_array[indexPath.row]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
