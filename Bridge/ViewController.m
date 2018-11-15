//
//  ViewController.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/17.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "ViewController.h"
#import "ActionDispose.h"
#import <WebKit/WebKit.h>
#import "WechatClass.h"
#import "JPUSHService.h"
#import <Gigi/Gigi.h>
#import "Toast+UIView.h"
#import <Photos/Photos.h>

#define getNavHight  self.navigationController.navigationBar.frame.size.height+[[UIApplication sharedApplication] statusBarFrame].size.height

extern id<BridgeDelegate>MapRequestDelegate;
extern id<BridgeDelegate>ScanRequestDelegate;
extern id<BridgeDelegate>PhotoRequestDelegate;
extern id<BridgeDelegate>WechatRequestDelegate;
extern id<BridgeDelegate>AlipayRequestDelegate;

@interface ViewController ()<WKUIDelegate,WKScriptMessageHandler,WKNavigationDelegate,WKHTTPCookieStoreObserver>
{
    NSString *_wxPaySuccessURL;
}

@property (atomic, strong)NSDictionary *shareParam;
@property (atomic, strong)NSDictionary *locParam;
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)NSString *firstCookie;
//加载进度条
@property (nonatomic, strong)UIProgressView *progressView;
//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
//刷新按钮
@property (nonatomic, strong) UIBarButtonItem *refreshItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //遵守数据回传代理
    MapRequestDelegate = self;
    ScanRequestDelegate = self;
    PhotoRequestDelegate = self;
    WechatRequestDelegate = self;
    AlipayRequestDelegate = self;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    // 定义拍照协议
    [config.userContentController addScriptMessageHandler:self name:PhotoProtocol];
    //定义定位协议
    [config.userContentController addScriptMessageHandler:self name:LocationProtocol];
    //定义导航协议
    [config.userContentController addScriptMessageHandler:self name:NavigationProtocol];
    //定义扫描协议
    [config.userContentController addScriptMessageHandler:self name:ScanProtocol];
    //定义分享协议
    [config.userContentController addScriptMessageHandler:self name:ShareProtocol];
    //定义支付协议
    [config.userContentController addScriptMessageHandler:self name:WXProtocol];
    //定义支付协议
    [config.userContentController addScriptMessageHandler:self name:AlipayProtocol];
    //定义缓存协议
    [config.userContentController addScriptMessageHandler:self name:CookieProtocol];
    //定义微信登录协议
    [config.userContentController addScriptMessageHandler:self name:WechatLoginProtocol];
    //定义保存图片协议
    [config.userContentController addScriptMessageHandler:self name:SavePhotoProtocol];
    //定义保存文字协议
    [config.userContentController addScriptMessageHandler:self name:SaveTextProtocol];
    
//    //从本地获取Cookie
//    _firstCookie = [self getCookie];
//    if (_firstCookie.length > 0) {
//        WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:_firstCookie injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//        [config.userContentController addUserScript:cookieScript];
//    }
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, SCREEN_HEIGHT - 24) configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    NSMutableURLRequest *request= [NSMutableURLRequest requestWithURL:[NSURL URLWithString:mainURL]];
//    if (_firstCookie.length > 0) {
//        [request setValue:_firstCookie forHTTPHeaderField:@"Cookie"];
//    }
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    [self addLeftButton];
    [self.view addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - OC Callback to JS
- (void)didRequestCompleted:(NSDictionary *)data{
    NSString *action = [data objectForKey:@"action"];
    NSString *returnString;
    NSString *callBack;
    if ([action isEqualToString:@"Location"]) {
        returnString = [NSString stringWithFormat:@"%@,%@",[data objectForKey:@"lat"],[data objectForKey:@"lng"]];
        callBack = @"GetLocCallBack";
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@','%@')",callBack,[data objectForKey:@"lat"],[data objectForKey:@"lng"]]  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
    }else if ([action isEqualToString:@"WXLogin"]){
        returnString = [data objectForKey:@"code"];
        callBack = @"wxLoginCallback";
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callBack,returnString]  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
    }else if ([action isEqualToString:@"WXPay"]){
        if ([self.webView canGoBack]) {
            [self.webView goBack];
            if ([self.webView canGoBack]) {
                [self.webView goBack];
            }
        }
        NSMutableURLRequest *request1 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_wxPaySuccessURL]];
        if (_firstCookie.length > 0) {
            [request1 setValue:_firstCookie forHTTPHeaderField:@"Cookie"];
        }
        [self.webView loadRequest:request1];
    }else if ([action isEqualToString:@"Alipay"]){
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }
        NSString *returnString = [data objectForKey:@"code"];
        NSString *callBack = @"aliPayCallback";
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callBack,returnString]  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
    }else if ([action isEqualToString:@"Scan"]){
        returnString = [data objectForKey:@"code"];
        callBack = @"qr_text";
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callBack,returnString]  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
    }else if ([action isEqualToString:@"Photo"]){
        returnString = [data objectForKey:@"image"];
        callBack = PhontCallback;
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%@')",callBack,returnString]  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
    }
}




- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *requestURL = navigationAction.request.URL.absoluteString;
    if (navigationAction.targetFrame == nil) {
        [self.webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - 在APP启动时，如果本地有Cookie就传给JS。必须要防止JS每次 重新location页面都调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (_firstCookie.length > 0) {
        [self.webView evaluateJavaScript:@"ocBridgeCallBack('')"  completionHandler:^(id item, NSError * _Nullable error) {
            NSLog(@"error:%@",error);
            if (!error) {
                _firstCookie = nil;
            }
        }];
    }
   
}

#pragma mark - 读取退出cookie
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    //读取wkwebview中的cookie 方法2 读取Set-Cookie字段
    NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
    NSLog(@"wkwebview中的cookie:%@,url:%@", cookieString,self.webView.URL);
    if ([self isContainExit:self.webView.URL.absoluteString]) {
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"Cookie"];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark -- 检测链接是否已经包含了exit=1
-(BOOL)isContainExit:(NSString*)urlStr
{
    return [urlStr containsString:@"exit=1"];
}

#pragma mark - JS调用OC
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSDictionary *param = [message.body objectForKey:@"parameters"];
    NSLog(@"name:%@:param:%@",message.name,param);
    //本人喜欢只定义一个MessageHandler协议 当然可以定义其他MessageHandler协议
    if ([message.name isEqualToString:PhotoProtocol])
    {
        [ActionDispose actionDispose:photoAction param:nil];
    }
    else if ([message.name isEqualToString:LocationProtocol]) {
        [ActionDispose actionDispose:locAction param:nil];
    }
    else if ([message.name isEqualToString:NavigationProtocol]) {
        [ActionDispose actionDispose:naviAction param:param];
    }
    else if ([message.name isEqualToString:ScanProtocol]) {
        [ActionDispose actionDispose:sacnAction param:nil];
    }
    else if ([message.name isEqualToString:ShareProtocol]) {
        [ActionDispose actionDispose:shareAction param:param];
    }
    else if ([message.name isEqualToString:WXProtocol]) {
        NSString *payString = [param objectForKey:@"payString"];
        _wxPaySuccessURL = [param objectForKey:@"url"];
        NSDictionary *dic = [[[self dictionaryWithJsonString:payString] objectForKey:@"data"] objectForKey:@"prepay"];
        [ActionDispose actionDispose:payAction param:dic];
    }
    else if ([message.name isEqualToString:CookieProtocol]){
        [self saveCookie:param];
        [self bindingJPush:param[@"UserID"]];
    }
    else if ([message.name isEqualToString:WechatLoginProtocol]){
        [ActionDispose actionDispose:wechatLoginAction param:@{}];
    }
    else if ([message.name isEqualToString:AlipayProtocol]){
        NSString *payString = [param objectForKey:@"payString"];
        NSDictionary *dic = @{@"payString":payString};
        [ActionDispose actionDispose:alipayPayAction param:dic];
    }
    else if ([message.name isEqualToString:SavePhotoProtocol]){
        
        NSMutableString *baseimg = [[NSMutableString alloc]initWithString:param[@"img"]];
        [baseimg deleteCharactersInRange:NSMakeRange(0, 22)];
        NSData *decodeData = [[NSData alloc]initWithBase64EncodedString:baseimg options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
        // 将NSData转为UIImage
        UIImage *decodedImage = [UIImage imageWithData: decodeData];
        [self savePhoto:decodedImage];
    }
    else if ([message.name isEqualToString:SaveTextProtocol]){
        [self pasteText:param[@"String"]];
    }
}

#pragma mark - 复制文字到剪切板
- (void)pasteText:(NSString *)text{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"内容已复制，可粘贴使用！" duration:1 position:@"center"];
    });
}

#pragma mark - 保存相片到相册
- (void)savePhoto:(UIImage *)image{
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            [self.view makeToast:@"相片保存失败" duration:1 position:@"center"];
            NSLog(@"%@",@"保存失败");
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"相片保存成功" duration:1 position:@"center"];
            });
        }
    }];
}

- (void)onFileInputClicked {
    [ActionDispose actionDispose:photoAction param:nil];
}

#pragma mark - 登录用户绑定极光推送
- (void)bindingJPush:(NSString *)user_id{
    NSSet *set = [[NSSet alloc]initWithObjects:user_id, nil];
    [JPUSHService setTags:set completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        
    } seq:1];
}

#pragma mark - 本地保存Cookie
- (void)saveCookie:(NSDictionary *)cookie{
    [[NSUserDefaults standardUserDefaults] setObject:cookie forKey:@"Cookie"];
}

#pragma mark - 本地取Cookie
- (NSString *)getCookie{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"Cookie"];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSArray *allKeys = [dic allKeys];
        NSMutableString *cookie = [[NSMutableString alloc]init];
        for (int i = 0; i<allKeys.count; ++i) {
            NSString *key = allKeys[i];
            NSString *value = [dic objectForKey:key];
            NSString *cur =[NSString stringWithFormat:@"'%@=%@'",key,value];
            [cookie appendString:cur];
        }
        return cookie;
    }
    else{
        return @"";
    }
}

#pragma mark - 字典转JSON
-(NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


#pragma mark - 拦截JS 弹窗
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    completionHandler();
//    //    NSLog(@"%s", __FUNCTION__);
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }]];
//
//    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    completionHandler(YES);
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler(NO);
//    }])];
//    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler(YES);
//    }])];
//    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 进度条
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.webView) {
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            if(self.webView.estimatedProgress >= 1.0f) {
                
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.progressView setAlpha:0.0f];
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]){
        if (object == self.webView) {
            self.title = self.webView.title;
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

#pragma mark - init

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, getNavHight, SCREEN_WIDTH, 2)];
    }
    return _progressView;
}

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //这是一张“<”的图片，可以让美工给切一张
        UIImage *image = [UIImage imageNamed:@"edaoxiu_leftarrow"];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitle:@"  返回" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backNative) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        //字体的多少为btn的大小
        [btn sizeToFit];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        btn.frame = CGRectMake(0, 10, 40, 40);
        _backItem.customView = btn;
    }
    return _backItem;
}

- (UIBarButtonItem *)refreshItem
{
    if (!_refreshItem) {
        _refreshItem = [[UIBarButtonItem alloc] init];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //这是一张“<”的图片，可以让美工给切一张
        UIImage *image = [UIImage imageNamed:@"edaoxiu_leftarrow"];
        [btn setImage:image forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [btn setTitle:@"刷新" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        //字体的多少为btn的大小
        [btn sizeToFit];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        //让返回按钮内容继续向左边偏移15，如果不设置的话，就会发现返回按钮离屏幕的左边的距离有点儿大，不美观
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        btn.frame = CGRectMake(0, 10, 40, 40);
        _refreshItem.customView = btn;
    }
    return _refreshItem;
}

//点击返回的方法
- (void)backNative
{
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        //同时设置返回按钮和关闭按钮为导航栏左边的按钮
    }
}

-(void)refreshView{
    [self.webView reload];
}
#pragma mark - 添加返回按钮

- (void)addLeftButton
{
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.navigationItem.rightBarButtonItem = self.refreshItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


