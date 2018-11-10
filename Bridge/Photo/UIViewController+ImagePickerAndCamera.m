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


const void * associateKey = @"ImagePickerAndCameraAssociateKey";

@implementation UIViewController (ImagePickerAndCamera)

- (void)setCompleteBlock:(void (^)(UIImage *))CompleteBlock{
    objc_setAssociatedObject(self, associateKey, CompleteBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UIImage*))CompleteBlock{
    return   objc_getAssociatedObject(self, associateKey);
}

// 创建弹出框来选择图片（相机相册两种方式）
- (void)createActionSheetForChooseImage:(void(^)(UIImage *))completeBlock{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"选择一种方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf localPhoto];
        }];
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            [weakSelf takePhoto];
        }];
    }]];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
    
    self.CompleteBlock = [completeBlock copy];
}

// 打开相机
- (void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            //设置拍照后的图片可被编辑
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请前往设置开启拍摄权限" message:@"没有拍摄权限，无法调用拍照功能" delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"好的", nil];
            alert.tag = 10;
            [alert show];
        }        
    }
    else
    {
    }
}


// 打开本地相册
- (void)localPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusAuthorized  || authStatus == ALAuthorizationStatusNotDetermined) {
            picker.delegate = self;
            //设置选择后的图片可被编辑
            picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请前往设置开启相册权限" message:@"没有相册权限，无法调用相册功能" delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"好的", nil];
            alert.tag = 10;
            [alert show];
        }
        
    }
    else{
    }
    
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if (UIImageJPEGRepresentation(image,0.3) != nil)
        {
            data = UIImageJPEGRepresentation(image, 0.3);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        image = [UIImage imageWithData:data];
        UIImage *image1 = [image imageByScalingAndCroppingForSize:CGSizeMake(300, 300)];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        self.CompleteBlock(image1);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
