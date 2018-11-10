//
//  netWorking.m
//  zaoyidongxin
//
//  Created by liluojian on 16/6/8.
//  Copyright © 2016年 gzgamut. All rights reserved.
//

#import "netWorking.h"
#import "XMLDictionary.h"
@implementation netWorking

+(void)getInitTypeblock:(void (^)(NSString *result, NSError *))block{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.winmobi.cn/api.ashx?action=getstatus&custid=%@",CLIENT_ID]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:15];
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *reponse = nil;
    NSError *erro = nil;
    NSData *syData = [NSURLConnection sendSynchronousRequest:request returningResponse:&reponse error:&erro];
    if (erro == nil) {
        if (syData != nil) {
            NSString *type =[[ NSString alloc] initWithData:syData encoding:NSUTF8StringEncoding];
            if (block) {
                block(type,nil);
            }
        }
    }
    else{
         block(nil, erro);
    }
    
}


#pragma mark - 微信
//第三方授权登录
+ (void)getWechatAccessTokenWithCode:(NSString *)code appid:(NSString *)appid secret:(NSString *)secret block:(void (^)(NSArray *, NSError *))block {
    /* 以下会创建一个异步http的get连接 */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", appid, secret, code]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:15];
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    //创建一个操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    //进行异步连接
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (block) {
                block([NSArray array], error);
            }
        } else {
            NSError *error2;
            NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error2];
            
            if (block) {
                block([NSArray arrayWithObject:allData],nil);
            }
        }
    }];
}
//获取微信用户资料
+ (void)getWechatUserInfoWithAccessToken:(NSString *)accessToken openid:(NSString *)openid block:(void (^)(NSArray *, NSError *))block {
    /* 以下会创建一个异步http的get连接 */
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openid]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:15];
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    //创建一个操作队列
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    //进行异步连接
    [NSURLConnection sendAsynchronousRequest:request queue:operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            if (block) {
                block([NSArray array], error);
            }
        } else {
            NSError *error2;
            NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error2];
            
            if (block) {
                block([NSArray arrayWithObject:allData],nil);
            }
        }
    }];
}
/*
 
 NSString *openid = [result objectForKey:@"openid"];
 NSString *nickname = [result objectForKey:@"nickname"];
 NSString *sex = [result objectForKey:@"sex"];
 NSString *province = [result objectForKey:@"province"];
 NSString *city = [result objectForKey:@"city"];
 NSString *country = [result objectForKey:@"country"];
 NSString *headimgurl = [result objectForKey:@"headimgurl"];
 NSString *unionid = [result objectForKey:@"unionid"];
 NSArray *privilege = [result objectForKey:@"privilege"];
 
 */
#pragma mark -- 提交微信登录open_id

+ (void)subWeChatOpenId:(NSString*)openId nickname:(NSString*)nickname sex:(NSString*)sex province:(NSString*)province city:(NSString*)city country:(NSString*)country unionid:(NSString*)unionid headimgurl:(NSString*)headimgurl block:(void (^)(id result, NSError *error))block
{
//    NSArray *arr = [[NSUserInfos getValueByKey:LoginPostUrl] componentsSeparatedByString:@"?"];
//    NSArray *arrBySame = [[arr lastObject] componentsSeparatedByString:@"="];
//    NSString *urlStr = [NSString stringWithFormat:@"%@",[NSUserInfos getValueByKey:LoginPostUrl]];  //可能带中文，需要转码
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithCapacity:0];
//    [parameters setObject:[arrBySame lastObject] forKey:[arrBySame firstObject]];
//    [parameters setObject:@"applogin" forKey:@"action"];
//
//    [parameters setObject:openId forKey:@"OpenID"];
//    [parameters setObject:nickname forKey:@"nickname"];
//    [parameters setObject:sex forKey:@"sex"];
//    [parameters setObject:province forKey:@"province"];
//    [parameters setObject:city forKey:@"city"];
//    [parameters setObject:country forKey:@"country"];
//    [parameters setObject:unionid forKey:@"unionid"];
//    [parameters setObject:headimgurl forKey:@"headimgurl"];
////    NSString *postStr = [parameters XMLString];
//
//    NSError *error;
//    //加载一个NSURL对象
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//    [request setTimeoutInterval:15];
//    [request setHTTPMethod:@"POST"];
//    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[country dataUsingEncoding:NSUTF8StringEncoding]];
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
//   // NSDictionary *dict2 = [NSDictionary dictionaryWithXMLData:response];
//    NSString *jsonStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
//
//    NSLog(@"%@",jsonStr);
  //  [parameters setObject:country forKey:@"JsonStr"];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
////    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    //这里传入的xml字符串只是形似xml，但是不是正确是xml格式，需要使用af方法进行转义
//    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
//    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[NSUserInfos getValueByKey:LoginPostUrl] forHTTPHeaderField:@"SOAPAction"];
//    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
//        return postStr;
//    }];
//    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer.timeoutInterval = 10;
//    
//    [manager POST:urlStr parameters:postStr progress:^(NSProgress * _Nonnull uploadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSData *data = responseObject;
//        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%s JSON: %@", __func__, dataStr);
//        NSData *newData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSError *error2;
//        NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:&error2];  //正常返回用户ID时的key为“userId”；返回错误信息时的key为“result”
//        
//        if([dataStr hasPrefix:@"接收到的OpenID"])
//        {
//            if(block)
//            {
//                block(@"1",nil);
//            }
//        }
//        else
//        {
//            
//        }
//        
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%s Error: %@", __func__, error);
//        if (block) {
//            block(nil, error);
//        }
//    }];
    
}

#pragma mark ---获取app配置接口
+(void)getAppSetByAppconfig:(NSString*)appconfig custid:(NSString*)custid block:(void (^)(id result, NSError *error))block
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/API.ashx", HEAD_URL];  //可能带中文，需要转码
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithCapacity:0];
    
    [parameters setObject:appconfig forKey:@"action"];
    [parameters setObject:custid forKey:@"custid"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSData *data = responseObject;
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *newData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error2;
        NSArray *allData = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:&error2];  //正常返回
        if(allData.count>0)
        {
            if(block)
            {
                block([allData firstObject],nil);
            }
        }
        else
        {
            if(block)
            {
                block(@"获取失败",nil);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s Error: %@", __func__, error);
        if (block) {
            block(nil, error);
        }
    }];

}

#pragma mark -- 获取订单详情
+(void)getOrderDeailByAction:(NSString*)Action OrderID:(NSString*)OrderID block:(void (^)(id result, NSError *error))block
{
//    NSString *urlStr = [[NSUserInfos getValueByKey:OrderMessageUrl] stringByAppendingString:OrderID];;  //可能带中文，需要转码
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithCapacity:0];
//  //  [parameters setObject:OrderID forKey:@"OrderID"];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer.timeoutInterval = 10;
//
//    [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSData *data = responseObject;
//        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%s JSON: %@", __func__, dataStr);
//        NSData *newData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSError *error2;
//        NSDictionary *allData = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:&error2];  //正常返回
//        if([allData isKindOfClass:[NSDictionary class]])
//        {
//            NSMutableArray *proArr = [NSMutableArray arrayWithCapacity:0];
//            orderDeailModel *ordModel = [[orderDeailModel alloc]init];
//            [ordModel setValuesForKeysWithDictionary:allData];
//            //解析商品
//            NSMutableArray *productArr = [NSMutableArray arrayWithCapacity:0];
//            for(NSDictionary *productDict in allData[@"item"])
//            {
//                productModel *proModel = [[productModel alloc]init];
//                [proModel setValuesForKeysWithDictionary:productDict];
//                [productArr addObject:proModel];
//            }
//            ordModel.itemArr = productArr;
//            [proArr addObject:ordModel];
//            if(block)
//            {
//                block(proArr,nil);
//            }
//        }
//        else
//        {
//            if(block)
//            {
//                block(@"获取失败",nil);
//            }
//        }
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%s Error: %@", __func__, error);
//        if (block) {
//            block(nil, error);
//        }
//    }];
//
}

#pragma mark -- 获取分享的内容
+(void)getShareContentByProductUrl:(NSString*)proUrl block:(void (^)(id result, NSError *error))block
{
//    NSString *urlStr = [NSString stringWithFormat:@"%@", [NSUserInfos getValueByKey:ShareAPIUrl]];  //可能带中文，需要转码
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]initWithCapacity:0];
//
//    [parameters setObject:proUrl forKey:@"Url"];
//
////   UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"post链接" message:proUrl delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
////    [alertV show];
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.requestSerializer.timeoutInterval = 10;
//
//    [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSData *data = responseObject;
//        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%s JSON: %@", __func__, dataStr);
//        NSData *newData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSError *error2;
//        id allData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];  //正常返回
//        if([allData isKindOfClass:[NSArray class]])
//        {
//            if(block)
//            {
//                block(allData,nil);
//            }
//        }
//        else
//        {
//            if(block)
//            {
//                block(@"获取失败",nil);
//            }
//        }
//
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%s Error: %@", __func__, error);
//        if (block) {
//            block(nil, error);
//        }
//    }];
}



@end
