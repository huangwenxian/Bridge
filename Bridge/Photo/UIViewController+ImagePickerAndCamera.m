//
//  UIViewController+ImagePickerAndCamera.m
//  XiuChe
//
//  Created by 朱健 on 16/5/25.
//  Copyright © 2016年 嗒嗒修车. All rights reserved.
//

#import "UIViewController+ImagePickerAndCamera.h"
#import <objc/runtime.h>
#import "UIImage+UIImageExt.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YBCustomCameraVC.h"
#import "BLImagePickerViewController.h"
#import "BLImageClipingViewController.h"
#import "SelectedImageVC.h"

const void * associateKey = @"ImagePickerAndCameraAssociateKey";

@implementation UIViewController (ImagePickerAndCamera)

- (void)setCompleteBlock:(void (^)(UIImage *))CompleteBlock{
    objc_setAssociatedObject(self, associateKey, CompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UIImage*))CompleteBlock{
    return   objc_getAssociatedObject(self, associateKey);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 2550) {
        if (buttonIndex == 0) {
            //拍照
            YBCustomCameraVC *vc = [[YBCustomCameraVC alloc]init];
            vc.CompleteBlock = ^(UIImage *image) {
                self.CompleteBlock(image);
            };
            [self presentViewController:vc animated:YES completion:nil];
        }else if (buttonIndex == 1) {
            //相册
            BLImagePickerViewController *imgVc = [[BLImagePickerViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:imgVc];
            imgVc.imageClipping = NO;
            imgVc.showCamera = NO;
            imgVc.maxNum = 1;
            imgVc.clippingItemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
            [imgVc initDataProgress:^(CGFloat progress) {
                
            } finished:^(NSArray<UIImage *> *resultAry, NSArray<PHAsset *> *assetsArry, UIImage *editedImage) {
                self.CompleteBlock(resultAry[0]);
                
            } cancle:^(NSString *cancleStr) {
                
            }];
            [self presentViewController:nav animated:YES completion:nil];
        }else if (buttonIndex == 2){
            return;
        }
    }
}

// 创建弹出框来选择图片（相机相册两种方式）
- (void)createActionSheetForChooseImage:(void(^)(UIImage *))completeBlock{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    sheet.tag = 2550;
    //显示消息框
    [sheet showInView:self.view];
    self.CompleteBlock = [completeBlock copy];
}


@end

