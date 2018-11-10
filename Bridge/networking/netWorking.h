//
//  netWorking.h
//  zaoyidongxin
//
//  Created by liluojian on 16/6/8.
//  Copyright © 2016年 gzgamut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#define HEAD_URL @"http://api.winmobi.cn"

//网络错误，只有文本
#define NETWORKERROR(x) [CommonUtils showMBProgressHUDWithText:@"网络异常，请检查你的网络设置！" inView:x]
//状态提示，只有文本
#define NETWORKSHOWTEXT(showText,inview) [CommonUtils showMBProgressHUDWithText:showText inView:inview]

//有圈有文本
#define SHOWLOADSTATUS(showText,inView) [CommonUtils showOnlyMBProgressHUDInView:inView withText:showText]
#define HIDESHOWLOADSTSTUS(inView) [CommonUtils hideMBProgressHUDInView:inView]

@interface netWorking : NSObject

+ (void)getWechatAccessTokenWithCode:(NSString *)code appid:(NSString *)appid secret:(NSString *)secret block:(void (^)(NSArray *, NSError *))block;

+ (void)getWechatUserInfoWithAccessToken:(NSString *)accessToken openid:(NSString *)openid block:(void (^)(NSArray *, NSError *))block;

#pragma mark -- 提交微信登录open_id

+ (void)subWeChatOpenId:(NSString*)openId nickname:(NSString*)nickname sex:(NSString*)sex province:(NSString*)province city:(NSString*)city country:(NSString*)country unionid:(NSString*)unionid headimgurl:(NSString*)headimgurl block:(void (^)(id result, NSError *error))block;

#pragma mark ---获取app配置接口
+(void)getAppSetByAppconfig:(NSString*)appconfig custid:(NSString*)custid block:(void (^)(id result, NSError *error))block;

#pragma mark -- 获取订单详情
+(void)getOrderDeailByAction:(NSString*)Action OrderID:(NSString*)OrderID block:(void (^)(id result, NSError *error))block;

#pragma mark -- 获取分享的内容
+(void)getShareContentByProductUrl:(NSString*)proUrl block:(void (^)(id result, NSError *error))block;

#pragma mark - 获取启动方式
+(void)getInitTypeblock:(void (^)(NSString* result, NSError *error))block;


@end
