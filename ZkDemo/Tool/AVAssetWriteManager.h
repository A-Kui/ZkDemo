//
//  AVAssetWriteManager.h
//  ZkDemo
//
//  Created by kui on 2021/6/22.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//录制状态，（这里把视频录制与写入合并成一个状态）
typedef NS_ENUM(NSInteger, FMRecordState) {
    FMRecordStateInit = 0,
    FMRecordStatePrepareRecording,//准备录制
    FMRecordStateRecording,//录制中
    FMRecordStateFinish,//录制完成
    FMRecordStateFail,//录制失败
};

typedef NS_ENUM(NSUInteger, CameraScaleType) {
    CameraScaleTypeDefault,//默认显示全屏
    CameraScaleType3X4,
    CameraScaleType1X1,
};
 
@protocol AVAssetWriteManagerDelegate <NSObject>
 
- (void)finishWriting;

- (void)updateWritingProgress:(CGFloat)progress;

@end

@interface AVAssetWriteManager : NSObject

@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, assign) FMRecordState writeState;
@property (nonatomic, weak) id <AVAssetWriteManagerDelegate> delegate;
- (instancetype)initWithURL:(NSURL *)URL viewType:(CameraScaleType )type outputSize:(CGSize)outputSize;

- (void)setUpInitWithType:(CameraScaleType )type outputSize:(CGSize)outputSize;

- (void)startWrite;
- (void)stopWrite;
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType;
- (void)destroyWrite;

@end
