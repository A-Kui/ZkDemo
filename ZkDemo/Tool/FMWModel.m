//
//  FMWModel.m
//  ZkDemo
//
//  Created by kui on 2021/6/22.
//

#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

#import "FMWModel.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XCFileManager.h"
#import "AVAssetWriteManager.h"


@interface FMWModel ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AVAssetWriteManagerDelegate,AVCapturePhotoCaptureDelegate>

@property (nonatomic, weak) UIView *superView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;

@property (nonatomic, strong)AVAssetWriteManager *writeManager;

@property (nonatomic, strong, readwrite) NSURL *videoUrl;

@property (nonatomic, assign) FMFlashState flashState;
@property (nonatomic, assign) CameraScaleType viewType;

//照片输出流
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;
@property (nonatomic, retain) AVCapturePhotoSettings *outputSettings;

@property (strong,nonatomic)  UIImageView *focusCursor; //聚焦光标
/// 支持分辨率
@property (nonatomic, assign) CGSize resolution;

@end

@implementation FMWModel
{
    BOOL isFlash;
}
- (instancetype)initWithVideoSuperView:(UIView *)superView
{
    self = [super init];
    if (self) {
        _superView = superView;
        [self setUp];
    }
    return self;
}

- (UIImageView *)focusCursor{
    if (!_focusCursor) {
        _focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
        _focusCursor.image = [UIImage imageNamed:@"hamburger.png"];
        _focusCursor.alpha = 0;
    }
    return _focusCursor;
}

#pragma mark - lazy load
- (AVCaptureSession *)session
{
    // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
    // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
    // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            _session.sessionPreset = AVCaptureSessionPreset1920x1080;
            _resolution = CGSizeMake(1080, 1920);
        }else if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
            _resolution = CGSizeMake(720, 1280);
        }else if ([_session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            _session.sessionPreset = AVCaptureSessionPreset640x480;
            _resolution = CGSizeMake(480, 640);
        }
    }
    return _session;
}

- (dispatch_queue_t)videoQueue
{
    if (!_videoQueue) {
        _videoQueue = dispatch_queue_create("com.5miles", DISPATCH_QUEUE_SERIAL);
    }
    return _videoQueue;
}
- (AVCaptureVideoPreviewLayer *)previewlayer
{
    if (!_previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewlayer;
}

- (void)setRecordState:(FMRecordState)recordState
{
    if (_recordState != recordState) {
        _recordState = recordState;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
            [self.delegate updateRecordState:_recordState];
        }
    }
}


#pragma mark - setup
- (void)setUp {
    ///1. 初始化捕捉会话，数据的采集都在会话中处理
    [self setUpInit];
    ///2. 设置视频的输入输出
    [self setUpVideo];
  
    ///4. 视频的预览层
    [self setUpPreviewLayer];
    
    ///5. 开始采集画面
    [self.session startRunning];
    
    /// 6. 初始化writer， 用writer 把数据写入文件
    [self setUpWriter];
    
    /// 7. 增加聚焦功能（可有可无）
    [self addFocus];
}

- (void)setUpVideo
{
    // 2.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    // 2.2 创建视频输入源
    NSError *error=nil;
    self.videoInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    // 2.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
    [self.videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if ([self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
    }
    
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
    _outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [self.imageOutput setPhotoSettingsForSceneMonitoring:_outputSettings];
    [self.session addOutput:self.imageOutput];
    
    self.device = [self.videoInput device];
    
}

- (void)setUpAudio
{
    // 2.2 获取音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error = nil;
    // 2.4 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    // 2.6 将音频输入源添加到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.audioOutput setSampleBufferDelegate:self queue:self.videoQueue];
    if([self.session canAddOutput:self.audioOutput]) {
        [self.session addOutput:self.audioOutput];
    }
    
}

- (void)setUpPreviewLayer{
    self.previewlayer.frame = [UIScreen mainScreen].bounds;
    [_superView.layer insertSublayer:self.previewlayer atIndex:0];
    [self.writeManager setUpInitWithType:1 outputSize:self.previewlayer.frame.size];
 
}

- (void)setUpWriter
{
    self.videoUrl = [[NSURL alloc] initFileURLWithPath:[self createVideoFilePath]];
    self.writeManager = [[AVAssetWriteManager alloc] initWithURL:self.videoUrl viewType:_viewType outputSize:self.resolution];
    self.writeManager.delegate = self;
  
     
}

//添加视频聚焦
- (void)addFocus {
    [self.superView addSubview:self.focusCursor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.superView addGestureRecognizer:tapGesture];
}

-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
      
    CGPoint point = [tapGesture locationInView:self.superView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewlayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
     
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickToFocus)]) {
        [self.delegate clickToFocus];
    }
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:0.8 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}

//设置聚焦点
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice = [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark - public method
//切换摄像头
- (void)turnCameraAction
{
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.videoInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];
    
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];
    
}

//闪光灯
- (void)switchflash:(BOOL)switchflash{
    
    AVCaptureTorchMode torch = switchflash ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
    
    if ([self.videoInput.device hasTorch]) {
        [self.videoInput.device lockForConfiguration:nil];
        [self.videoInput.device setTorchMode:torch];
        [self.videoInput.device unlockForConfiguration];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateFlashState:)]) {
        [self.delegate updateFlashState:_flashState];
    }
    
    isFlash = switchflash;
    
}
 
/// 开始录制
/// @param soundSwitch 声音开关
- (void)startRecordWithSoundSwitch:(BOOL)soundSwitch {

    if (self.recordState == FMRecordStateInit) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.writeManager startWrite];
            self.recordState = FMRecordStateRecording;
        });
        
    }
    
    [self setUpAudio];
    [self switchflash:isFlash];
}

/// 停止录制
/// @param soundSwitch 声音开关
- (void)stopRecordWithSoundSwitch:(BOOL)soundSwitch {

    [self.session removeInput:self.audioInput];
    [self.session removeOutput:self.audioOutput];
    
    [self.writeManager stopWrite];
    [self.session stopRunning];
    self.recordState = FMRecordStateFinish;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self switchflash:self->isFlash];
    });
}

- (void)reset
{
    self.recordState = FMRecordStateInit;
    [self.session startRunning];
    [self setUpWriter];
    
}


#pragma mark - private method
//初始化设置
- (void)setUpInit
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBack) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoFocus) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.device];
 
    _recordState = FMRecordStateInit;
}

- (void)autoFocus {
     
    if (_device.isFocusPointOfInterestSupported && [_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error = nil;
        [_device lockForConfiguration:&error];
        [_device setFocusMode:AVCaptureFocusModeAutoFocus];
        [_device unlockForConfiguration];
    }
    
}

//存放视频的文件夹
- (NSString *)videoFolder
{
    NSString *cacheDir = [XCFileManager cachesDir];
    NSString *direc = [cacheDir stringByAppendingPathComponent:VIDEO_FOLDER];
    if (![XCFileManager isExistsAtPath:direc]) {
        [XCFileManager createDirectoryAtPath:direc];
    }
    return direc;
}
 
//写入的视频路径
- (NSString *)createVideoFilePath
{
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
}

#pragma mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        //视频
        if (connection == [self.videoOutput connectionWithMediaType:AVMediaTypeVideo]) {
              
            if (!self.writeManager.outputVideoFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputVideoFormatDescription = formatDescription;
                }
            } else {
                @synchronized(self) {
                    if (self.writeManager.writeState == FMRecordStateRecording) {
                        [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
                    }
                    
                }
            }
            
            
        }
        
        //音频
        if (connection == [self.audioOutput connectionWithMediaType:AVMediaTypeAudio]) {
            if (!self.writeManager.outputAudioFormatDescription) {
                @synchronized(self) {
                    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                    self.writeManager.outputAudioFormatDescription = formatDescription;
                }
            }
            @synchronized(self) {
                
                if (self.writeManager.writeState == FMRecordStateRecording) {
                    [self.writeManager appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
                }
                
            }
            
        }
    }
    
    
    
}

#pragma mark--拍照
- (void)getTakePicture {
  
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
    AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    [self.imageOutput capturePhotoWithSettings:outputSettings delegate:self];
    
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error {

    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *image = [UIImage imageWithData:data];

    CGRect outputRect = [self.previewlayer metadataOutputRectOfInterestForRect:self.previewlayer.bounds];
    CGImageRef takenCGImage = image.CGImage;
    size_t width = CGImageGetWidth(takenCGImage);
    size_t height = CGImageGetHeight(takenCGImage);
    CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);

    CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
    image = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:image.imageOrientation];
    CGImageRelease(cropCGImage);


    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCompletedWithImage:)]) {
        [self.delegate photoCompletedWithImage:image];
    }

}


#pragma mark - AVAssetWriteManagerDelegate
- (void)updateWritingProgress:(CGFloat)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
        [self.delegate updateRecordingProgress:progress];
    }
}

- (void)finishWriting
{
    [self.session stopRunning];
    self.recordState = FMRecordStateFinish;
}
#pragma mark - notification
- (void)enterBack
{
    self.videoUrl = nil;
    [self.session stopRunning];
    [self.writeManager destroyWrite];
   
}

- (void)becomeActive
{
    [self reset];
}


- (void)destroy
{
    [self.session stopRunning];
    self.session = nil;
    self.videoQueue = nil;
    self.videoOutput = nil;
    self.videoInput = nil;
    self.audioOutput = nil;
    self.audioInput = nil;
    [self.writeManager destroyWrite];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [self destroy];
    
}
@end
