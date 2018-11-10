//
//  AlipayClass.h
//  ZPBridge
//
//  Created by hoolai on 2018/8/21.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlipayClass : NSObject

+ (void)startAliPay:(NSDictionary *)alipayParam;//支付宝支付

+ (void)returnAliPayCode:(NSString *)alipayCode;
@end
