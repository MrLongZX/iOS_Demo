//
//  XJClusterAnnotationView.h
//  taohuadao
//
//  Created by taohuadao on 2016/12/7.
//  Copyright © 2016年 诗颖. All rights reserved.
//

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@class YLClusterAnnotationView,YLCluster;

@protocol YLClusterAnnotationViewDelegate <NSObject>

- (void)didAddreesWithClusterAnnotationView:(YLCluster *)cluster clusterAnnotationView:(YLClusterAnnotationView *)clusterAnnotationView;

@end

@interface YLClusterAnnotationView : BMKPinAnnotationView

@property (nonatomic, copy)NSString *title;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) YLCluster *cluster;

@property (nonatomic, weak)id <YLClusterAnnotationViewDelegate>delegate;

@end
