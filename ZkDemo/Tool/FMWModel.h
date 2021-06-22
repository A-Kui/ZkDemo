//
//  FMWModel.h
//  ZkDemo
//
//  Created by kui on 2021/6/22.
//

#import <Foundation/Foundation.h>
#import "AVAssetWriteManager.h"
#import <UIKit/UIKit.h>

//闪光灯状态
typedef NS_ENUM(NSInteger, FMFlashState) {
    FMFlashClose = 0,
    FMFlashOpen,
    FMFlashAuto,
};

@protocol FMWModelDelegate <NSObject>

/// 拍照完成
/// @param image 图片
- (void)photoCompletedWithImage:(UIImage *)image;

/// 更新闪光灯状态
/// @param state 状态
- (void)updateFlashState:(FMFlashState)state;

/// 录制进度
/// @param progress 进度
- (void)updateRecordingProgress:(CGFloat)progress;

/// 更新录制状态
/// @param recordState 状态
- (void)updateRecordState:(FMRecordState)recordState;

/// 点击聚焦
- (void)clickToFocus;

@end
 
@interface FMWModel : NSObject

@property (nonatomic, weak  ) id<FMWModelDelegate>delegate;
@property (nonatomic, assign) FMRecordState recordState;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, strong) AVCaptureDevice *device;

- (instancetype)initWithVideoSuperView:(UIView *)superView;

- (void)setUpPreviewLayerWithType:(CameraScaleType )type;
 
/// 拍照
- (void)getTakePicture;

/// 切换摄像头
- (void)turnCameraAction;

/// 闪光灯
/// @param switchflash YES开
- (void)switchflash:(BOOL)switchflash;

/// 开始录制
/// @param soundSwitch 声音开关
- (void)startRecordWithSoundSwitch:(BOOL)soundSwitch;
  
/// 停止录制
/// @param soundSwitch 声音开关
- (void)stopRecordWithSoundSwitch:(BOOL)soundSwitch;
  
/// 重置
- (void)reset;


@end
