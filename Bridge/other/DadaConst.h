//
//  DadaConst.h
//  dadaxiuche
//
//  Created by terryh on 16/4/19.
//  Copyright © 2016年 ddxc. All rights reserved.
//

#ifndef DadaConst_h
#define DadaConst_h

//新版本需要用到的宏
#define CLIENT_ID @"102243"    //商户唯一ID，必须配置对
#define mainURL @"http://www.baidu.com/"//https://qt.qtlight.com/home/moto
#define weChatAppId @"wx0d4ab2b757694cbd"
#define JPush  @"9bb492e2156cb03e732c189a"


//JS调用OC协议
#define PhotoProtocol  @"Photo"
#define LocationProtocol @"getLocBySDK"
#define NavigationProtocol @"Navigation"
#define ScanProtocol @"Scan"
#define ShareProtocol @"shareImageToWechat"
#define WXProtocol @"wxPay"
#define AlipayProtocol @"AliPay"
#define CookieProtocol @"Cookie"
#define WechatLoginProtocol  @"wxLogin"
#define SavePhotoProtocol  @"SavePhoto"
#define SaveTextProtocol  @"SaveText"

//OC调用JS callback函数
#define WXLoginCallback  @"wxLoginCallback"
#define WXPayCallback  @""//不需要返回，只要跳转对应URL即可
#define LocationCallback  @"GetLocCallBack"
#define AlipayCallback  @"aliPayCallback"
#define PhontCallback  @"AppReturnBase64Image"

//屏幕
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCAL  ([UIScreen mainScreen].bounds.size.height/667)

static NSString * const ErrorMessageStringNetwotkError  = @"请检查网络，稍候再试！";


#endif /* DadaConst_h */
