//
//  MRCTableViewController.h
//  MVVMReactiveCocoa
//
//  Created by leichunfeng on 14/12/27.
//  Copyright (c) 2014年 leichunfeng. All rights reserved.
//

#import "MRCViewController.h"

@interface MRCTableViewController : MRCViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

/// The table view for tableView controller.
@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, assign, readonly) UIEdgeInsets contentInset;
/// 下拉刷新控件
@property (nonatomic, strong, readonly) CBStoreHouseRefreshControl *refreshControl;

/// 刷新table view
- (void)reloadData;
/// 获取indexPath对应的cell
- (UITableViewCell *)tableView:(UITableView *)tableView dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
/// 配置cell
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

@end
