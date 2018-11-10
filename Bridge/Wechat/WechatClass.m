//
//  LoginClass.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/17.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "WechatClass.h"
#import "netWorking.h"
#import "BridgeDelegate.h"

#define SceneTimeline  @"timeline"
#define SceneSession  @"session"

id<BridgeDelegate>WechatRequestDelegate;

@implementation WechatClass

+ (void)WXLogin{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state = @"jiaguwen-shop";
    //第三方向微信终端发送一个SendAuthReq消息结构
    BOOL isSuccess = [WXApi sendReq:req];
    if (isSuccess) {
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付失败" message:@"拉起微信支付失败，请联系商家" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

+ (void)startWechatPay:(NSDictionary *)wechatParam{
    //调起微信支付
    PayReq *req = [[PayReq alloc] init];
    req.openID = [wechatParam objectForKey:@"appid"];
    req.partnerId = [wechatParam objectForKey:@"partnerid"];
    req.prepayId = [wechatParam objectForKey:@"prepayid"];
    req.nonceStr = [wechatParam objectForKey:@"noncestr"];
    req.timeStamp = [[wechatParam objectForKey:@"timestamp"] intValue];
    req.package = [wechatParam objectForKey:@"package"];
    req.sign = [wechatParam objectForKey:@"sign"];
    BOOL isSuccess = [WXApi sendReq:req];
    if (isSuccess) {
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付失败" message:@"拉起微信支付失败，请联系商家" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

+ (void)WXShare:(NSString *)type shareImg:(NSString *)imgUrl{
    if ([WXApi isWXAppInstalled]) {
        WXImageObject *ext = [WXImageObject object];
        // 小于10MB
        ext.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.mediaObject = ext;
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        if ([type isEqualToString:SceneTimeline]) {
            req.scene = WXSceneTimeline;//分享微信朋友圈
        }else{
            req.scene = WXSceneSession;//分享微信好友
        }
        [WXApi sendReq:req];
    }
    
}




//微信登录回调
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *temp = (SendAuthResp*)resp;
        NSLog(@">>微信 errorCode=%d", temp.errCode);  //0：用户同意；-4：用户拒绝授权；-2：用户取消
        
        if (temp.errCode == 0) {
            
            NSDictionary *loginParam = @{@"action":@"WXLogin",
                                       @"code":temp.code
                                       };
            [WechatRequestDelegate didRequestCompleted:loginParam];
        }
        else if (resp.errCode == -2)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"用户取消授权" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"未知错误" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            
        }
    }
    else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        NSString *text = @"";
        if (resp.errCode == 0) {
            text = @"分享成功";
        } else {
            text = @"分享失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    else if ([resp isKindOfClass:[PayResp class]])
    {
        NSString *text = @"";
        if(resp.errCode == 0)
        {
            text = @"支付成功";
            NSDictionary *loginParam = @{@"action":@"WXPay",
                                         @"code":@""
                                         };
            [WechatRequestDelegate didRequestCompleted:loginParam];
            return;
        }
        else if(resp.errCode == -2)
        {
            text = @"用户取消支付";
        }
        else
        {
            text = @"支付失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}


@end
