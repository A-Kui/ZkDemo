//
//  AVAssetWriteManager.m
//  ZkDemo
//
//  Created by kui on 2021/6/22.
//
#define RECORD_MAX_TIME 60.0           //最长录制时间
#define TIMER_INTERVAL 0.05         //计时器刷新频率

#import "AVAssetWriteManager.h"
#import "XCFileManager.h"
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVAssetWriteManager ()


@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) NSURL           *videoUrl;

@property (nonatomic, strong)AVAssetWriter *assetWriter;

@property (nonatomic, strong)AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong)AVAssetWriterInput *assetWriterAudioInput;



@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;


@property (nonatomic, assign) BOOL canWrite;
@property (nonatomic, assign) CameraScaleType viewType;


@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat recordTime;

@property (nonatomic, assign) CGSize ratioSize;

@end

@implementation AVAssetWriteManager

#pragma mark - private method
- (void)setUpInitWithType:(CameraScaleType )type outputSize:(CGSize)outputSize
{
 
    self.ratioSize = CGSizeMake(outputSize.width, outputSize.height);
    _writeQueue = dispatch_queue_create("com.5miles", DISPATCH_QUEUE_SERIAL);
    _recordTime = 0;
}

- (instancetype)initWithURL:(NSURL *)URL viewType:(CameraScaleType )type outputSize:(CGSize)outputSize
{
    self = [super init];
    if (self) {
        _videoUrl = URL;
        _viewType = type;
        [self setUpInitWithType:type outputSize:outputSize];
        
    }
    return self;
}

//开始写入数据
- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
    if (sampleBuffer == NULL){
        NSLog(@"empty sampleBuffer");
        return;
    }
    
    @synchronized(self){
        if (self.writeState < FMRecordStateRecording){
            NSLog(@"not ready yet");
            return;
        }
    }
     
    CFRetain(sampleBuffer);
    dispatch_async(self.writeQueue, ^{
        @autoreleasepool {
            @synchronized(self) {
                if (self.writeState > FMRecordStateRecording){
                    CFRelease(sampleBuffer);
                    return;
                }
            }
             
            if (!self.canWrite && mediaType == AVMediaTypeVideo) {
                [self.assetWriter startWriting];
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.canWrite = YES;
            }
            
            if (!self->_timer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->_timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
                });
                
            }
            //写入视频数据
            if (mediaType == AVMediaTypeVideo) {
                if (self.assetWriterVideoInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            //写入音频数据
            if (mediaType == AVMediaTypeAudio) {
                if (self.assetWriterAudioInput.readyForMoreMediaData) {
                    BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                    if (!success) {
                        @synchronized (self) {
                            [self stopWrite];
                            [self destroyWrite];
                        }
                    }
                }
            }
            
            CFRelease(sampleBuffer);
        }
    } );
}



#pragma mark - public methed
- (void)startWrite
{
    self.writeState = FMRecordStatePrepareRecording;
    if (!self.assetWriter) {
        [self setUpWriter];
    }
    
    
}
- (void)stopWrite
{
    self.writeState = FMRecordStateFinish;
    [self.timer invalidate];
    self.timer = nil;
    __weak __typeof(self)weakSelf = self;
    if(_assetWriter && _assetWriter.status == AVAssetWriterStatusWriting){
        dispatch_async(self.writeQueue, ^{
            [self->_assetWriter finishWritingWithCompletionHandler:^{
//                ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//                [lib writeVideoAtPathToSavedPhotosAlbum:weakSelf.videoUrl completionBlock:nil];
                
                NSLog(@"%@",weakSelf.videoUrl);

            }];
        });
    }
}

- (void)updateProgress
{
    if (_recordTime >= RECORD_MAX_TIME) {
        [self stopWrite];
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishWriting)]) {
            [self.delegate finishWriting];
        }
        return;
    }
    _recordTime += TIMER_INTERVAL;
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateWritingProgress:)]) {
        [self.delegate updateWritingProgress:_recordTime/RECORD_MAX_TIME * 1.0];
    }
}

#pragma mark - private method
//设置写入视频属性
- (void)setUpWriter
{
    self.assetWriter = [AVAssetWriter assetWriterWithURL:self.videoUrl fileType:AVFileTypeMPEG4 error:nil];
     
    //写入视频大小
    NSInteger numPixels = self.ratioSize.width * self.ratioSize.height;
    //每像素比特
    NSLog(@"setUpWriter=W:%f--H:%f",self.ratioSize.width,self.ratioSize.height);
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    //视频属性
    self.videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                       AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(self.ratioSize.height),
                                       AVVideoHeightKey : @(self.ratioSize.width),
                                       AVVideoCompressionPropertiesKey : compressionProperties };

    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:self.videoCompressionSettings];
    //expectsMediaDataInRealTime 必须设为yes，需要从capture session 实时获取数据
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
     
    // 音频设置
    self.audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                       AVNumberOfChannelsKey : @(1),
                                       AVSampleRateKey : @(22050) };
     
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:self.audioCompressionSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
     
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"AssetWriter videoInput append Failed");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"AssetWriter audioInput Append Failed");
    }
     
    self.writeState = FMRecordStateRecording;
     
}


//检查写入地址
- (BOOL)checkPathUrl:(NSURL *)url
{
    if (!url) {
        return NO;
    }
    if ([XCFileManager isExistsAtPath:[url path]]) {
        return [XCFileManager removeItemAtPath:[url path]];
    }
    return YES;
}

- (void)destroyWrite
{
    self.assetWriter = nil;
    self.assetWriterAudioInput = nil;
    self.assetWriterVideoInput = nil;
    self.videoUrl = nil;
    self.recordTime = 0;
    [self.timer invalidate];
    self.timer = nil;
    
}

- (void)dealloc
{
    [self destroyWrite];
}

@end
