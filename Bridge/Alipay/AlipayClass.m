//
//  AlipayClass.m
//  ZPBridge
//
//  Created by hoolai on 2018/8/21.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "AlipayClass.h"
#import <AlipaySDK/AlipaySDK.h>
#import "BridgeDelegate.h"

id<BridgeDelegate>AlipayRequestDelegate;

@implementation AlipayClass

+(void)startAliPay:(NSString *)alipayParam{
    [[AlipaySDK defaultService] payOrder:alipayParam fromScheme:[[NSBundle mainBundle] bundleIdentifier] callback:^(NSDictionary *resultDic) { // 网页版
        NSLog(@"支付宝支付结果 reslut = %@", resultDic);
        
        // 返回结果需要通过 resultStatus 以及 result 字段的值来综合判断并确定支付结果。 在 resultStatus=9000,并且 success="true"以及 sign="xxx"校验通过的情况下,证明支付成功。其它情况归为失败。较低安全级别的场合,也可以只通过检查 resultStatus 以及 success="true"来判定支付结果
        
        if (resultDic && [resultDic objectForKey:@"resultStatus"] && ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000)) {
            
            
        } else {
            
         
        }
    }];
}

+ (void)returnAliPayCode:(NSString *)alipayCode{
    
    NSDictionary *payParam = @{@"action":@"Alipay",
                                 @"code":alipayCode
                                 };
    [AlipayRequestDelegate didRequestCompleted:payParam];
}

@end
