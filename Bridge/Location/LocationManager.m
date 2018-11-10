//
//  LocationManager.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/17.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "LocationManager.h"
#import "CLLocation+YCLocation.h"
#import <MapKit/MapKit.h>

#define openBaidumap  [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]
#define openGaodemap  [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]
#define openQQmap  [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]

#define baidumap @"百度地图"
#define gaodemap  @"高德地图"
#define qqmap  @"腾讯地图"
#define applemap  @"苹果地图"

id<BridgeDelegate>MapRequestDelegate;

@implementation LocationManager


+ (instancetype)sharedInstance {
    static LocationManager* instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
    });
    return instance;
}

#pragma mark - 懒加载
- (CLLocationManager *)manager
{
    if (_manager == nil) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

#pragma 获取经纬度
- (void)getCurLocation{
    [self.manager requestWhenInUseAuthorization];
    self.isFirst = YES;//每次进来重置
    _manager.delegate = self;
    _manager.desiredAccuracy = kCLLocationAccuracyBest;
    CLLocationDistance distance = 1000.0;
    _manager.distanceFilter = distance;
    [_manager startUpdatingLocation];
}



#pragma mark - 导航
- (void)naviToLocation:(NSDictionary *)loc FromeVC:(UIViewController *)curVC{
    _isNavi = YES;
    [self getCurLocation];
    CLLocationDegrees toLat = [[loc objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees toLon = [[loc objectForKey:@"longitude"] doubleValue];
    _toLoc = [[CLLocation alloc]initWithLatitude:toLat longitude:toLon];
    NSMutableArray *maps = [[NSMutableArray alloc]init];
    if (openBaidumap) {
        [maps addObject:baidumap];
    }
    if (openGaodemap) {
        [maps addObject:gaodemap];
    }
    if (openQQmap) {
        [maps addObject:qqmap];
    }
    [maps addObject:applemap];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择导航使用的地图应用" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < maps.count; ++i) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:maps[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _isNavi = NO;//无论选择了什么，都认为本次调用结束
            if ([action.title isEqualToString:applemap]) {
                [self openAppleMap];
            }else if ([action.title isEqualToString:baidumap]){
                [self openBaiduMap];
            }else if ([action.title isEqualToString:gaodemap]){
                [self openGaodeMap];
            }else if ([action.title isEqualToString:qqmap]){
                [self openQQMap];
            }
        }];
        [alertVC addAction:action];
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:action];
    
    [curVC presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - 打开苹果地图
- (void)openAppleMap{
    
    CLLocationCoordinate2D from =_curLoc.coordinate;
    MKPlacemark *curPlacemark = [[MKPlacemark alloc]initWithCoordinate:from];
    MKMapItem *curItem = [[MKMapItem alloc]initWithPlacemark:curPlacemark];
    curItem.name = @"我的位置";
    
    //终点
    CLLocationCoordinate2D to =_toLoc.coordinate;
    MKPlacemark *toPlacemark = [[MKPlacemark alloc]initWithCoordinate:to];
    MKMapItem *toItem = [[MKMapItem alloc]initWithPlacemark:toPlacemark];
    curItem.name = @"终点";
    
    NSArray *items = [NSArray arrayWithObjects:curItem,toItem,nil];
    NSDictionary *options =@{
                             MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsMapTypeKey:
                                 [NSNumber numberWithInteger:MKMapTypeStandard],
                             MKLaunchOptionsShowsTrafficKey:@YES
                             };
    
    //打开苹果自身地图应用
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark - 打开高德地图
- (void)openGaodeMap{
    
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",_curLoc.coordinate.latitude,_curLoc.coordinate.longitude,@"我的位置",_toLoc.coordinate.latitude,_toLoc.coordinate.longitude,@"终点"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *r = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:r];
}

#pragma mark - 打开百度地图
- (void)openBaiduMap{
    //需要转换坐标系
    CLLocation *newCurLoc = [_curLoc locationMarsFromBaidu];
    CLLocation *newToLoc = [_toLoc locationMarsFromBaidu];
    NSString *stringURL = [NSString stringWithFormat:@"baidumap://map/direction?origin=%f,%f&destination=%f,%f&&mode=driving",newCurLoc.coordinate.latitude,newCurLoc.coordinate.longitude,newToLoc.coordinate.latitude,newToLoc.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:stringURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)openQQMap{
    //需要转换坐标系
    CLLocation *newCurLoc = [_curLoc locationMarsFromBaidu];
    CLLocation *newToLoc = [_toLoc locationMarsFromBaidu];
    NSString *urlStr = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&fromcoord=%f,%f&tocoord=%f,%f&policy=1",newCurLoc.coordinate.latitude,newCurLoc.coordinate.longitude,newToLoc.coordinate.latitude,newToLoc.coordinate.longitude];
    NSURL *r = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:r];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations[0];//获取最新的地理位置
    _curLoc = [location locationBaiduFromMars];
    //Latitude 纬度   longitude经度
    CLLocation *newCurLoc = [_curLoc locationMarsFromEarth];
    NSString *lat = [NSString stringWithFormat:@"%f",newCurLoc.coordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f",newCurLoc.coordinate.longitude];
    NSDictionary *locParam = @{@"action":@"Location",
                               @"lat":lat,
                               @"lng":lon
                               };
    if (!_isNavi && _isFirst) {
        [MapRequestDelegate didRequestCompleted:locParam];
        _isFirst = NO;
    }
    
    [_manager stopUpdatingLocation];
}

// 代理方法中监听授权的改变,被拒绝有两种情况,一是真正被拒绝,二是服务关闭了
//这里需要永久存储用户对定位权限的选择。
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户未决定");
            break;
        }
            // 系统预留字段,暂时还没用到
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"受限制");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 被拒绝有两种情况 1.设备不支持定位服务 2.定位服务被关闭
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"真正被拒绝");
                // 跳转到设置界面
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            else {
                NSLog(@"没有开启此功能");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"前后台定位授权");
            [_manager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"前台定位授权");
            [_manager startUpdatingLocation];
            break;
        }
        default:
            break;
    }
}



@end
