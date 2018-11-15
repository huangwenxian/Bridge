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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 2550) {
        NSUInteger sourceType = 0;
        // 判断系统是否支持相机
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.delegate = self; //设置代理
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType; //图片来源
            if (buttonIndex == 0) {
                //拍照
                sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.sourceType = sourceType;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }else if (buttonIndex == 1) {
                //相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePickerController.sourceType = sourceType;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }else if (buttonIndex == 2){
                return;
            }
        }else {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.sourceType = sourceType;
            [self presentViewController:imagePickerController animated:YES completion:nil];
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
        
        //关闭相册、相机界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        self.CompleteBlock(image1);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
