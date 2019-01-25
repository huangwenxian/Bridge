//
//  SelectPhoto.m
//  ZPBridge
//
//  Created by hoolai on 2019/1/4.
//  Copyright © 2019 黄文先. All rights reserved.
//

#import "RTPhotoManager.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

typedef void(^PHAssetCollectionBlock)(NSMutableArray <PHAssetCollection *> * collections);
typedef void(^PHAssetPhotoBlock)(NSMutableArray <PHAsset *> * photos);
typedef void(^PHImgBlock)(UIImage * images);

@interface RTPhotoManager ()
@property (nonatomic,strong) NSMutableArray<PHAssetCollection*>* collections; //存放所有相薄

@end

@implementation RTPhotoManager

-(instancetype)init
{
    if (self = [super init])
    {
        self.collections = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}


+(instancetype)shareInstance
{
    static RTPhotoManager * photoManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoManager = [[RTPhotoManager alloc]init];
    });
    
    return photoManager;
}

/**
 获得所有的自定义相簿和获得相机胶卷
 
 @param successBlock 成功是回调的block
 */
-(void)openPhotosCollectionSuccess:(PHAssetCollectionBlock)successBlock {
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self.collections addObject:cameraRoll];
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self.collections addObject:assetCollection];
    }
    successBlock(self.collections);
}

/**
 遍历相簿中的所有图片资源
 
 @param assetCollection 相簿
 @param synchronous     是否同步
 @param successBlock    成功是回调的block
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection isSynchronous:(BOOL)synchronous  Success:(PHAssetPhotoBlock)successBlock {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = synchronous;
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    NSMutableArray *assetPhotos = [[NSMutableArray alloc]init];
    for (PHAsset *asset in assets) {
        [assetPhotos addObject:asset];
    }
    successBlock(assetPhotos);
}

/**
 从图片资源获得图片Image
 
 @param asset         图片资源
 @param successBlock 成功是回调的block
 @param isThumbnail  是否要缩略图
 */
- (void)getImagesFromPHAsset:(PHAsset*)asset Success:(PHImgBlock)successBlock isGetThumbnailImage:(BOOL)isThumbnail
{
    CGSize size = CGSizeZero;
    if (!isThumbnail) {
        size =CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        successBlock(result);
    }];
    
}




@end
