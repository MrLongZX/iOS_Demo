//
//  XJClusterController.m
//  taohuadao
//
//  Created by taohuadao on 2016/12/5.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import "YLClusterController.h"
#import "UIView+Extension.h"
#import <CoreLocation/CLAvailability.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

#import "BMKClusterManager.h"
#import "YLClusterAnnotation.h"
#import "YLClusterAnnotationView.h"
#import "YLCluster.h"

#define animationTime 0.5
#define viewMultiple 2
#define XJ_OffsetX 15
#define ScreenSize [UIScreen mainScreen].bounds.size

@interface YLClusterController ()<UIGestureRecognizerDelegate,BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,YLClusterAnnotationViewDelegate>
{
    BMKMapView        *_mapView;
    BMKClusterManager *_clusterManager;//点聚合管理类
    NSMutableArray    *_clusterCaches;//点聚合缓存标注
    NSInteger         _clusterZoom;//聚合级别
}

@property (nonatomic, strong)BMKPoiSearch           *poiSearch;
@property (nonatomic, strong)BMKLocationService     *locationService;
@property (nonatomic, assign)CLLocationCoordinate2D centerCoordinate;//当前地图的中心点

@end

@implementation YLClusterController

#pragma mark - 懒加载
- (BMKPoiSearch *)poiSearch {
    if (!_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc] init];
        _poiSearch.delegate = self;
    }
    return _poiSearch;
}

#pragma mark - 生命周期
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locationService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    [_locationService stopUserLocationService];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点聚合";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMapView];
    [self initLocationService];
}

#pragma mark - 初始化地图
- (void)initMapView {
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64, ScreenSize.width, ScreenSize.height-64)];
    _mapView.gesturesEnabled = YES;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    [self.view addSubview:_mapView];
}

#pragma mark - 初始化定位服务
- (void)initLocationService {
    _locationService = [[BMKLocationService alloc]init];
    _locationService.desiredAccuracy =  kCLLocationAccuracyBest;
    _locationService.distanceFilter = 10;
    [_locationService startUserLocationService];
    
    _clusterManager = [[BMKClusterManager alloc] init];
    //在此处理正常结果
    _clusterCaches = [[NSMutableArray alloc] init];
    for (NSInteger i = 3; i < 22; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
}

//更新聚合状态
- (void)updateClusters {
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterCaches) {
            NSMutableArray *clusters = [NSMutableArray array];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //获取聚合后的标注
                __block NSArray *array = [_clusterManager getClusters:_clusterZoom];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (BMKCluster *item in array) {
                        YLClusterAnnotation *annotation = [[YLClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.size = item.size;
                        annotation.title = item.title;
                        annotation.cluster = item.cluster;
                        [clusters addObject:annotation];
                    }
                    [_mapView removeOverlays:_mapView.overlays];
                    [_mapView removeAnnotations:_mapView.annotations];
                    [_mapView addAnnotations:clusters];

                });
            });
        }
}

#pragma mark - BMKMapViewDelegate
//地图初始化完毕时会调用此接口
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    //精度圈是否显示
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isAccuracyCircleShow = NO;
    [_mapView updateLocationViewWithParam:displayParam];
    
    self.centerCoordinate = _mapView.centerCoordinate;
    //设定当前地图的显示范围
    BMKCoordinateRegion region ;
    region.center = _mapView.centerCoordinate;
    region.span.latitudeDelta = 0.2;
    region.span.longitudeDelta = 0.2;
    [_mapView setRegion:region animated:YES];
    //更新点聚合
    [self updateClusters];
}

//地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    //调用过“更新点聚合”方法 并且地图显示比例等级已经修改
    if (_clusterZoom != 0 && _clusterZoom != (NSInteger)mapView.zoomLevel) {
        [self updateClusters];
    }
}

//地图区域改变完成后会调用此接口
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //用周边检索获取的数据 当做模拟数据
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.pageIndex = 1;
    option.pageCapacity = 10;
    option.location = mapView.centerCoordinate;
    option.keyword = @"小吃";
    BOOL flag = [self.poiSearch poiSearchNearBy:option];
    if (flag) {
        NSLog(@"周边检索发送成功");
    } else {
        NSLog(@"周边检索发送失败");
    }
}

//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    NSString *AnnotationViewID = @"ClusterMark";
    YLClusterAnnotation *cluster = (YLClusterAnnotation*)annotation;
    YLClusterAnnotationView *annotationView = [[YLClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    annotationView.title = cluster.title;
    annotationView.size = cluster.size;
    annotationView.cluster = cluster.cluster;
    annotationView.delegate = self;
    annotationView.canShowCallout = NO;
    annotationView.draggable = NO;
    annotationView.annotation = cluster;
    
    UIView *viewForImage=[[UIView alloc]init];
    UIImageView *imageview=[[UIImageView alloc]init];
    CGSize contentSize = [self contentSizeWithTitle:cluster.title];
    [viewForImage setFrame:CGRectMake(0, 0, (contentSize.width + XJ_OffsetX ) *viewMultiple, (contentSize.height + XJ_OffsetX ) *viewMultiple)];
    [imageview setFrame:CGRectMake(0, 0, (contentSize.width + XJ_OffsetX ) *viewMultiple, (contentSize.height + XJ_OffsetX ) *viewMultiple)];
    annotationView.xj_size = CGSizeMake(contentSize.width, contentSize.height);
    
    [imageview setImage:[UIImage imageNamed:@"kong"]];
    imageview.layer.masksToBounds=YES;
    imageview.layer.cornerRadius = 10;
    [viewForImage addSubview:imageview];
    
    annotationView.image = [self getImageFromView:viewForImage];
    return annotationView;
}

//计算文字的高度
- (CGSize)contentSizeWithTitle:(NSString *)title {
    CGSize maxSize = CGSizeMake(ScreenSize.width *0.5, MAXFLOAT);
    return  [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size;
}

//根据view上下文生成图片
-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//当选中一个annotation views时，调用此接口
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    YLClusterAnnotationView *clusterAnnotation = (YLClusterAnnotationView*)view.annotation;
    if ([clusterAnnotation.title isEqualToString:@"我的位置"]) {
        [self positionButtonClick];
        return;
    }
    NSLog(@"点击了：%@", clusterAnnotation.title);
}

//点击“我的位置”
- (void)positionButtonClick {
    //设定当前地图的显示范围
    BMKCoordinateRegion region ;
    region.center = self.centerCoordinate;
    region.span.latitudeDelta = 0.002;
    region.span.longitudeDelta = 0.002;
    [_mapView setRegion:region animated:YES];
}

//当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view {
    if ([view isKindOfClass:[YLClusterAnnotationView class]]) {
        YLClusterAnnotationView *clusterAnnotation = (YLClusterAnnotationView*)view.annotation;
        if (clusterAnnotation.size > 3) {
            [mapView setCenterCoordinate:view.annotation.coordinate];
            [mapView zoomIn];
        }
    }
}

#pragma mark -- BMKLocationServiceDelegate 
//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    //更新地图用户位置，设置用户位置为地图中心点
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate];
    [self updateClusters];
}

//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"定位失败：error %@",error);
}

#pragma mark -- BMKPoiSearchDelegate 
//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {//在此处理正常结果
        [_clusterManager clearClusterItems];
        for (BMKPoiInfo *poiInfo in poiResultList.poiInfoList) {
            YLCluster *cluster = [[YLCluster alloc] init];
            cluster.name = poiInfo.name;
            cluster.pt = poiInfo.pt;
            [self addAnnoWithPT:cluster];
        }
    } else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){//检索词有岐义
        NSLog(@"检索词有岐义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark - 添加cluster
- (void)addAnnoWithPT:(YLCluster *)cluster {
    BMKClusterItem *clusterItem = [[BMKClusterItem alloc] init];
    clusterItem.coor = cluster.pt;
    clusterItem.title = cluster.name;
    clusterItem.cluster = cluster;
    [_clusterManager addClusterItem:clusterItem];
}

#pragma mark - XJClusterAnnotationViewDelegate
- (void)didAddreesWithClusterAnnotationView:(YLCluster *)cluster clusterAnnotationView:(YLClusterAnnotationView *)clusterAnnotationView{
    if (clusterAnnotationView.size > 3) {
        [_mapView setCenterCoordinate:clusterAnnotationView.annotation.coordinate];
        [_mapView zoomIn];
    }
}

- (void)dealloc {
    _mapView.delegate = nil;
    if (_mapView) {
        _mapView = nil;
    }
    _locationService.delegate = nil;
    _poiSearch = nil;
}

@end
