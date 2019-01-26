//
//  WeiBoClass.m
//  ZPBridge
//
//  Created by hoolai on 2019/1/26.
//  Copyright © 2019 黄文先. All rights reserved.
//

#import "WeiBoClass.h"
#import "WeiboSDK.h"

@implementation WeiBoClass

+ (void)WBShare:(NSString *)type shareImg:(NSDictionary *)param{
    WBMessageObject *message = [WBMessageObject message];
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = param[@"tite"];
    webpage.description = param[@"content"];
    webpage.thumbnailData = [NSData dataWithContentsOfURL:[NSURL URLWithString:param[@"img"]]];
    webpage.webpageUrl = param[@"link"];
    message.mediaObject = webpage;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

@end
