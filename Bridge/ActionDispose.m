//
//  ActionDispose.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/20.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "ActionDispose.h"
#import "LocationManager.h"
#import "Scan.h"
#import "Photo.h"
#import "WechatClass.h"
#import "AlipayClass.h"
#import "WeiBoClass.h"

@implementation ActionDispose

+ (void)actionDispose:(requestAction)action param:(NSDictionary *)param{
    switch (action) {
        case photoAction:
            [Photo toPhotoFromeVC:[self topViewController]];
            break;
        case locAction:
           [[LocationManager sharedInstance]getCurLocation];
            break;
        case naviAction:
            [[LocationManager sharedInstance]naviToLocation:param FromeVC:[self topViewController]];
            break;
        case sacnAction:
            [Scan toScanQRCodeFromeVC:[self topViewController]];
            break;
        case shareAction:{
            NSString *type = param[@"type"];
            if ([type isEqualToString:@"timeline"] ||[type isEqualToString:@"session"]) {
                [WechatClass WXShare:type shareImg:param];
            }else if ([type isEqualToString:@"qq"]){
                
            }else if ([type isEqualToString:@"weibo"]){
                [WeiBoClass WBShare:type shareImg:param];
            }
        }
            
            break;
        case payAction:
            [WechatClass startWechatPay:param];
            break;
        case alipayPayAction:
            [AlipayClass startAliPay:param[@"payString"]];
            break;
        case wechatLoginAction:
            [WechatClass WXLogin];
            break;
        default:
            break;
    }
    
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
