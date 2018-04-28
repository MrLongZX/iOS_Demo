//
//  MainViewController.m
//  Applications
//
//  Created by Ignacio on 6/6/14.
//  Copyright (c) 2014 DZN Labs. All rights reserved.
//

#import "MainViewController.h"
#import "UIColor+Hexadecimal.h"

// 导入框架
#import <DZNEmptyDataSet/DZNEmptyDataSet.h>

// 遵循协议
@interface MainViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, strong) NSArray *applications;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation MainViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"applications" ofType:@"json"];
    self.applications = [Application applicationsFromJSONAtPath:path];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Applications";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    
    self.tableView.tableFooterView = [UIView new];
    
    // 设置table代理为空白页框架代理
    self.searchDisplayController.searchResultsTableView.emptyDataSetSource = self;
    self.searchDisplayController.searchResultsTableView.emptyDataSetDelegate = self;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    [self.searchDisplayController setValue:@"" forKey:@"noResultsMessage"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Resets styling
    self.navigationController.navigationBar.titleTextAttributes = nil;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:@"f8f8f8"];;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - Getters
// 过滤数据
- (NSArray *)filteredApps
{
    UISearchBar *searchBar = self.searchDisplayController.searchBar;

    if ([searchBar isFirstResponder] && searchBar.text.length > 0)
    {
        NSPredicate *precidate = [NSPredicate predicateWithFormat:@"displayName CONTAINS[cd] %@", searchBar.text];
        return [self.applications filteredArrayUsingPredicate:precidate];
    }
    return self.applications;
}


#pragma mark - DZNEmptyDataSetSource Methods 空白页数据代理
// 设置标题
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Application Found";
    return [[NSAttributedString alloc] initWithString:text attributes:nil];
}

// 设置描述文字
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    UISearchBar *searchBar = self.searchDisplayController.searchBar;
    
    NSString *text = [NSString stringWithFormat:@"There are no empty dataset examples for \"%@\".", searchBar.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:[attributedString.string rangeOfString:searchBar.text]];
    
    return attributedString;
}

// 按钮标题属性
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSString *text = @"Search on the App Store";
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = [UIColor colorWithHex:(state == UIControlStateNormal) ? @"007aff" : @"c6def9"];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

// 背景颜色
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor whiteColor];
}

// 垂直部分的偏移
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -64.0;
}

#pragma mark - DZNEmptyDataSetDelegate Methods 空白页行为代理
// 数据源为空时，是否渲染和展示(默认为 YES)
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

// 是否允许点击 (默认为 YES)
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

// 是否允许滚动 (默认为 NO)
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

// 处理空白区域的点击事件
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    NSLog(@"%s",__FUNCTION__);
}

// 处理按钮的点击事件
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{

    UISearchBar *searchBar = self.searchDisplayController.searchBar;

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.com/apps/%@", searchBar.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = [self filteredApps].count;

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"app_cell_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    Application *app = [[self filteredApps] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = app.displayName;
    cell.detailTextLabel.text = app.developerName;
    
    UIImage *image = [UIImage imageNamed:app.iconName];
    cell.imageView.image = image;
    
    cell.imageView.layer.cornerRadius = image.size.width*0.2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    cell.imageView.layer.borderWidth = 0.5;
    
    cell.imageView.layer.shouldRasterize = YES;
    cell.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Application *app = [[self filteredApps] objectAtIndex:indexPath.row];
    DetailViewController *controller = [[DetailViewController alloc] initWithApplication:app];
    controller.applications = self.applications;
    controller.allowShuffling = YES;
    
    if ([controller preferredStatusBarStyle] == UIStatusBarStyleLightContent) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UISearchBarDelegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    // Do something
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    // Do something
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // Do something
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Do something
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Do something
}


#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    // Do something
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // Do something
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    // Do something
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    // Do something
}


#pragma mark - View Auto-Rotation

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
