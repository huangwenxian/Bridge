//
//  Scan.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/21.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "Scan.h"
#import "scanViewController.h"
id<BridgeDelegate>ScanRequestDelegate;


@implementation Scan

+ (void)toScanQRCodeFromeVC:(UIViewController *)controller{
    
    scanViewController *scanVC = [[scanViewController alloc]init];
    [scanVC returnBlock:^(NSString *str) {
        [ScanRequestDelegate didRequestCompleted:@{@"action":@"Scan",
                                                   @"code":str
                                                   }];
    }];
    [controller  presentViewController:scanVC animated:YES completion:nil];
}

@end
