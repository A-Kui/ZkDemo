//
//  DiyCameraVC.m
//  ZkDemo
//
//  Created by kui on 2021/6/22.
//

#import "DiyCameraVC.h"
#import "FMWModel.h"
#import <Photos/Photos.h>

@interface DiyCameraVC ()<FMWModelDelegate>

@property (nonatomic, strong) FMWModel *model;
 
@end

@implementation DiyCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.model = [[FMWModel alloc]initWithVideoSuperView:self.view];
    self.model.delegate = self;
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //拍照
    [self.model getTakePicture];
  
}

/// 拍照完成
/// @param image 图片
- (void)photoCompletedWithImage:(UIImage *)image {
    NSLog(@"%@",image);
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        NSLog(@"%@",req);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
    
    }];
}

@end
