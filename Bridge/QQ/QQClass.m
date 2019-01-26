//
//  QQClass.m
//  ZPBridge
//
//  Created by hoolai on 2019/1/26.
//  Copyright © 2019 黄文先. All rights reserved.
//

#import "QQClass.h"
#import <TencentOpenAPI/TencentOAuth.h>

@implementation QQClass

+ (void)QQShare:(NSString *)type shareImg:(NSDictionary *)param{
    NSURL *url = [NSURL URLWithString:param[@"link"]];
    NSURL *preimageUrl = [NSURL URLWithString:param[@"img"]];
//    QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:_webModel.title description:[NSString stringWithFormat:@"%@",_webModel.content] previewImageURL:preimageUrl];
//
//
//    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
//
//    appdelegate.qqDelegate = self;
//
//    QQApiSendResultCode sent = [QQApiInterface sendReq:req];//分享给QQ好友
//
//    [self handleSendResult:sent];
}

@end
