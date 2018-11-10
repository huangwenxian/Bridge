//
//  BridgeDelegate.h
//  Bridge
//
//  Created by 黄文先 on 2018/3/21.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BridgeDelegate <NSObject>

@optional

-(void)didRequestCompleted:(NSDictionary *)data;//这个不好区分，所以用下面的
//-(void)didPhotoRequestCompleted:(NSDictionary *)data;//拍照回调代理
//-(void)didMapRequestCompleted:(NSDictionary *)data;//定位回调代理
//-(void)didScanRequestCompleted:(NSDictionary *)data;//扫描回调代理
//-(void)didShareRequestCompleted:(NSDictionary *)data;//分享回调代理
//-(void)didPayRequestCompleted:(NSDictionary *)data;//支付回调代理

@end
