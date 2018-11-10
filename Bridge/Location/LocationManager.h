//
//  LocationManager.h
//  Bridge
//
//  Created by 黄文先 on 2018/3/17.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>
#import "BaseObject.h"


@interface LocationManager : BaseObject<CLLocationManagerDelegate>

@property(nonatomic,strong) CLLocationManager *manager;
@property (nonatomic, assign)BOOL isNavi;
@property (nonatomic, strong)CLLocation *curLoc;
@property (nonatomic, strong)CLLocation *toLoc;
@property (nonatomic, assign)BOOL isFirst;//系统定位回调方法会多次回调，防止多次回调给网页


+ (instancetype)sharedInstance;
//定位是异步回调。所以需要使用异步回调
- (void)getCurLocation;

- (void)naviToLocation:(NSDictionary *)loc FromeVC:(UIViewController *)curVC;

@end
