//
//  Photo.m
//  Bridge
//
//  Created by 黄文先 on 2018/3/21.
//  Copyright © 2018年 黄文先. All rights reserved.
//

#import "Photo.h"
#import "UIViewController+ImagePickerAndCamera.h"

id<BridgeDelegate>PhotoRequestDelegate;

@implementation Photo

+(void)toPhotoFromeVC:(UIViewController *)controller{
    
    [[UIApplication sharedApplication].keyWindow.rootViewController createActionSheetForChooseImage:^(UIImage *image) {
        [PhotoRequestDelegate didRequestCompleted:@{@"action":@"Photo",
                                                    @"image":[self UIImageToBase64Str:image]
                                                    }];
    }];
}

+ (NSString *)UIImageToBase64Str:(UIImage *) image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSMutableString *mutEncodedImageStr = [NSMutableString stringWithFormat:@"data:image/png;base64,%@",encodedImageStr];

    NSString *newEncodedImageStr = [self removeSpaceAndNewline:mutEncodedImageStr];
    return newEncodedImageStr;
}

+ (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}



@end
