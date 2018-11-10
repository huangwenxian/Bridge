//
//  scanViewController.m
//  ScudMan
//
//  Created by apple on 15/9/24.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "scanViewController.h"
#import <AVFoundation/AVFoundation.h>
#define SCANVIEW_EdgeTop 80.0
#define SCANVIEW_EdgeLeft 50.0
#define TINTCOLOR_ALPHA 0.2 //浅色透明度
#define DARKCOLOR_ALPHA 0.5 //深色透明度

@interface scanViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    UIView *_QrCodeline;
    NSTimer *_timer;
    //设置扫描画面
    UIView *_scanView;
    UIImageView *imageview;
    UILabel *label;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;


@end

@implementation scanViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)returnBlock:(transferBlock)block
{
    _block = block;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
}

- (void)back:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UILabel *titleL = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    titleL.text = @"扫描二维码";
    titleL.textColor = [UIColor blackColor];
    titleL.font = [UIFont systemFontOfSize:16];
    titleL.textAlignment = 1;
    [topView addSubview:titleL];
    
    UIButton *backBT = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 60, 44)];
    [backBT setTitle:@"返回" forState:UIControlStateNormal];
    [backBT setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBT.font = [UIFont systemFontOfSize:14];
    [backBT addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBT];
    
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    _output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeQRCode];
    [_output setRectOfInterest:CGRectMake((124)/SCREEN_HEIGHT,((SCREEN_WIDTH-220)/2)/SCREEN_WIDTH,220/SCREEN_HEIGHT,220/SCREEN_WIDTH)];

    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view.layer insertSublayer:_preview atIndex:0];
    [self setScanView];
    [self.view addSubview:_scanView];
    [_session startRunning];
    [ self createTimer ];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        [self stopTimer];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        [self dismissViewControllerAnimated:YES completion:nil];
        _block(stringValue);
    }
}

//二维码的扫描区域
- ( void )setScanView
{
    _scanView =[[ UIView alloc ] initWithFrame : CGRectMake ( 0 , 64 , SCREEN_WIDTH , SCREEN_HEIGHT - 64 )];
    _scanView . backgroundColor =[ UIColor clearColor];
    //最上部view
    UIView * upView = [[ UIView alloc ] initWithFrame : CGRectMake ( 0, 0 , SCREEN_WIDTH , SCANVIEW_EdgeTop )];
    upView. alpha = TINTCOLOR_ALPHA ;
    upView. backgroundColor = [ UIColor blackColor ];
    [ _scanView addSubview :upView];
    //左侧的view
    UIView *leftView = [[ UIView alloc ] initWithFrame : CGRectMake ( 0 , SCANVIEW_EdgeTop , SCANVIEW_EdgeLeft , SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft )];
    leftView. alpha = TINTCOLOR_ALPHA ;
    leftView. backgroundColor = [ UIColor blackColor];
    [ _scanView addSubview :leftView];
    
    /******************中间扫描区域****************************/
    UIImageView *scanCropView=[[ UIImageView alloc ] initWithFrame : CGRectMake ( SCANVIEW_EdgeLeft , SCANVIEW_EdgeTop , SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft , SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft )];
    //scanCropView.image=[UIImage imageNamed:@""];
    scanCropView.layer.borderColor =[UIColor whiteColor].CGColor;
    scanCropView. layer . borderWidth = 2.0 ;
    scanCropView. backgroundColor =[ UIColor clearColor ];
    [ _scanView addSubview :scanCropView];
    //右侧的view
    UIView *rightView = [[ UIView alloc ] initWithFrame : CGRectMake ( SCREEN_WIDTH - SCANVIEW_EdgeLeft , SCANVIEW_EdgeTop , SCANVIEW_EdgeLeft , SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft)];
    rightView. alpha = TINTCOLOR_ALPHA ;
    rightView. backgroundColor = [ UIColor blackColor];
    [ _scanView addSubview :rightView];
    //底部view
    UIView *downView = [[ UIView alloc ] initWithFrame : CGRectMake ( 0 ,SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop , SCREEN_WIDTH , SCREEN_HEIGHT -( SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop )- 64 )];
    //downView.alpha = TINTCOLOR_ALPHA;
    downView. backgroundColor = [[ UIColor blackColor] colorWithAlphaComponent : TINTCOLOR_ALPHA ] ;
    [ _scanView addSubview :downView];
    //用于说明的label
    UILabel *labIntroudction= [[ UILabel alloc ] init ];
    labIntroudction. backgroundColor = [ UIColor clearColor ];
    labIntroudction. frame = CGRectMake ( 0 , 5 , SCREEN_WIDTH , 20 );
    labIntroudction. numberOfLines = 1 ;
    labIntroudction. font =[ UIFont systemFontOfSize : 15.0 ];
    labIntroudction. textAlignment = NSTextAlignmentCenter ;
    labIntroudction. textColor =[ UIColor whiteColor ];
    labIntroudction. text = @"将二维码对准方框，即可自动扫描" ;
    [downView addSubview :labIntroudction];
    UIView *darkView = [[ UIView alloc ] initWithFrame : CGRectMake ( 0 , downView. frame . size . height - 100.0 , SCREEN_WIDTH , 100.0 )];
    darkView. backgroundColor = [[ UIColor blackColor ]  colorWithAlphaComponent : DARKCOLOR_ALPHA ];
    [downView addSubview :darkView];
    
    //用于开关灯操作的button
    UIButton *openButton=[[ UIButton alloc ] initWithFrame : CGRectMake (0 , 20 , SCREEN_WIDTH , 40.0 )];
    [openButton setTitle : @"开启闪光灯" forState: UIControlStateNormal ];
    [openButton setTitleColor :[ UIColor whiteColor ] forState : UIControlStateNormal ];
    openButton. titleLabel.textAlignment = NSTextAlignmentCenter ;
    openButton. titleLabel.font =[ UIFont systemFontOfSize : 22.0 ];
    [openButton addTarget:self action:@selector (openLight) forControlEvents:UIControlEventTouchUpInside ];
    [darkView addSubview :openButton];
    //画中间的基准线
    _QrCodeline = [[ UIView alloc ] initWithFrame : CGRectMake ( SCANVIEW_EdgeLeft , SCANVIEW_EdgeTop , SCREEN_WIDTH - 2 * SCANVIEW_EdgeLeft , 2 )];
    _QrCodeline.backgroundColor = [ UIColor whiteColor];
    [_scanView addSubview : _QrCodeline ];
    
}


- (void)openLight
{
    AVCaptureDevice *device = self.device;
    
    //修改前必须先锁定
    [self.device lockForConfiguration:nil];
    
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([self.device hasFlash]) {
        
        if (self.device.flashMode == AVCaptureFlashModeOff) {
            self.device.flashMode = AVCaptureFlashModeOn;
            self.device.torchMode = AVCaptureTorchModeOn;
        } else if (self.device.flashMode == AVCaptureFlashModeOn) {
            self.device.flashMode = AVCaptureFlashModeOff;
            self.device.torchMode = AVCaptureTorchModeOff;
        }
        
    }
    [device unlockForConfiguration];
}
- ( void )viewWillDisappear:( BOOL )animated
{
    [ super viewWillDisappear :animated];
    [_session stopRunning];
    [ self stopTimer ];
}
//二维码的横线移动
- ( void )moveUpAndDownLine
{
    CGFloat Y= _QrCodeline . frame . origin . y ;
    //CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH-2*SCANVIEW_EdgeLeft, 1)]
    if (SCREEN_WIDTH- 2 *SCANVIEW_EdgeLeft+SCANVIEW_EdgeTop==Y){
        [UIView beginAnimations: @"asa" context: nil ];
        [UIView setAnimationDuration: 1 ];
        _QrCodeline.frame=CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, SCREEN_WIDTH- 2 *SCANVIEW_EdgeLeft, 1 );
        [UIView commitAnimations];
    } else if (SCANVIEW_EdgeTop==Y){
        [UIView beginAnimations: @"asa" context: nil ];
        [UIView setAnimationDuration: 1 ];
        _QrCodeline.frame=CGRectMake(SCANVIEW_EdgeLeft, SCREEN_WIDTH- 2 *SCANVIEW_EdgeLeft+SCANVIEW_EdgeTop, SCREEN_WIDTH- 2 *SCANVIEW_EdgeLeft, 1 );
        [UIView commitAnimations];
    }
}
- ( void )createTimer
{
    //创建一个时间计数
    _timer=[NSTimer scheduledTimerWithTimeInterval: 2.0 target: self selector: @selector (moveUpAndDownLine) userInfo: nil repeats: YES ];
}
- (void)stopTimer
{
    if ([_timer isValid] == YES ) {
        [_timer invalidate];
        _timer = nil ;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
