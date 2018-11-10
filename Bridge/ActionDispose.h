//
//  ActionDispose.h
//  Bridge
//
//  Created by 黄文先 on 2018/3/20.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    photoAction = 0,
    locAction,
    naviAction,
    sacnAction,
    shareAction,
    payAction,
    wechatLoginAction,
    alipayPayAction
} requestAction;


@interface ActionDispose : NSObject

+ (void)actionDispose:(requestAction)action param:(NSDictionary *)param;

@end
