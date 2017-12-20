//
//  AppDelegate.h
//  BaiduMapDemo
//
//  Created by 苏友龙 on 2017/11/18.
//  Copyright © 2017年 Pulian. All rights reserved.
//

#import <UIKit/UIKit.h>
 #import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;


@end

