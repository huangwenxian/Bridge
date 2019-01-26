//
//  LoginClass.h
//  Bridge
//
//  Created by 黄文先 on 2018/3/17.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WechatClass : NSObject<WXApiDelegate>

+ (void)WXLogin;

+ (void)startWechatPay:(NSDictionary *)wechatParam;//微信支付

+ (void)WXShare:(NSString *)type shareImg:(NSDictionary *)param;

@end
