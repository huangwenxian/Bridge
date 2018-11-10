//
//  UIViewController+ImagePickerAndCamera.h
//  XiuChe
//
//  Created by 朱健 on 16/5/25.
//  Copyright © 2016年 嗒嗒修车. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ImagePickerAndCamera)<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, copy) void (^CompleteBlock)(UIImage*);

// 创建弹出框来选择图片（相机相册两种方式）
- (void)createActionSheetForChooseImage:(void(^)(UIImage *))completeBlock;

@end
