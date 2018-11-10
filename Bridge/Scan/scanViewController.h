//
//  scanViewController.h
//  ScudMan
//
//  Created by apple on 15/9/24.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^transferBlock)(NSString *str);
@interface scanViewController : UIViewController  //
//用于传值的Block
@property(nonatomic, copy)transferBlock block;
//赋值
- (void)returnBlock:(transferBlock)block;

@end
