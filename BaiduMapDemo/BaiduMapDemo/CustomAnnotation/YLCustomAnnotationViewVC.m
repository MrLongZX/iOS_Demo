//
//  CustomAnnotationViewVC.m
//  BaiduMapDemo
//
//  Created by 苏友龙 on 2017/11/19.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import "YLCustomAnnotationViewVC.h"
#import "YLIconTitleAnnotaView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件

@interface YLCustomAnnotationViewVC ()<BMKMapViewDelegate,BMKLocationServiceDelegate>

/** mapView */
@property (nonatomic, strong) BMKMapView *mapView;
/** locationService */
@property (nonatomic, strong) BMKLocationService *locationService;

@end

@implementation YLCustomAnnotationViewVC


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    
    //添加完代理后 再添加大头针 才会执行viewForAnnotation方法
    [self addCustomPointAnnotation];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    
    [_locationService stopUserLocationService];
    _locationService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMapView];
    [self initlocationService];
}

- (void)initMapView {
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    [self.view addSubview:_mapView];
}

-(void)initlocationService{
    _locationService = [[BMKLocationService alloc] init];
    _locationService.desiredAccuracy = kCLLocationAccuracyBest;
    _locationService.distanceFilter = 100;
    _locationService.delegate = self;
    [_locationService startUserLocationService];
}

- (void)addCustomPointAnnotation{
    BMKPointAnnotation *pointAnnotation1 = [[BMKPointAnnotation alloc]init];
    pointAnnotation1.coordinate = CLLocationCoordinate2DMake(36.66439086, 117.13704588);
    
    BMKPointAnnotation *pointAnnotation2 = [[BMKPointAnnotation alloc]init];
    pointAnnotation2.coordinate = CLLocationCoordinate2DMake(36.676439046, 117.10704538);

    BMKPointAnnotation *pointAnnotation3 = [[BMKPointAnnotation alloc]init];
    pointAnnotation3.coordinate = CLLocationCoordinate2DMake(36.69439086, 117.15704588);
    
    NSArray *arr = @[pointAnnotation1,pointAnnotation2,pointAnnotation3];
    [_mapView addAnnotations:arr];
}

#pragma mark --- BMKMapViewDelegate
//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    //使用自定义大头针
    static NSString *identifier = @"renameMark";
    YLIconTitleAnnotaView *annotationView = (YLIconTitleAnnotaView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView) {
        annotationView = [[YLIconTitleAnnotaView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    annotationView.canShowCallout = NO;
    annotationView.titleStr = @"112";
    annotationView.image = [UIImage imageNamed:@"gas_coor"];
    return annotationView;
}

//当选中一个annotation views时，调用此接口
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"didSelect");
}

//当取消选中一个annotation views时，调用此接口
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view{
    NSLog(@"didDeselect");
}

#pragma mark --- BMKLocationServiceDelegate
//用户方向更新后，会调用此函数
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation{
    NSLog(@"heading is %@",userLocation.heading);
}

//用户位置更新后，会调用此函数
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    [_mapView updateLocationData:userLocation];
    [_mapView setCenterCoordinate:userLocation.location.coordinate];
}

//定位失败后，会调用此函数
- (void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"error:%@",error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
