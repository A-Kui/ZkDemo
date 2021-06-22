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
 
    UIImage *newImage = [self imageWithClippedRect:CGRectMake(0, 0, image.size.width / 2, image.size.height / 2) image:image];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:newImage];
        NSLog(@"%@",req);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
    
    }];
}

/// 剪裁图片
/// @param rect 剪裁坐标
/// @param image 剪裁图片
- (UIImage *)imageWithClippedRect:(CGRect)rect image:(UIImage *)image {
    
    [self inspectContextSize:rect.size];
    
    CGRect imageRect = CGRectMakeWithSize(rect.size);
    if (CGRectContainsRect(rect, imageRect)) {
        // 要裁剪的区域比自身大，所以不用裁剪直接返回自身即可
        rect.size = image.size;
    }
    // 由于CGImage是以pixel为单位来计算的，而UIImage是以point为单位，所以这里需要将传进来的point转换为pixel
    CGRect scaledRect = CGRectApplyScale(rect, image.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, scaledRect);
    UIImage *imageOut = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return imageOut;
}


- (void)inspectContextSize:(CGSize)size {
    if (!CGSizeIsValidated(size)) {
        NSAssert(NO, @"QMUI CGPostError, %@:%d %s, 非法的size：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, NSStringFromCGSize(size), [NSThread callStackSymbols]);
    }
}

/// 为一个CGRect叠加scale计算
CG_INLINE CGRect
CGRectApplyScale(CGRect rect, CGFloat scale) {
    return CGRectFlatted(CGRectMake(CGRectGetMinX(rect) * scale, CGRectGetMinY(rect) * scale, CGRectGetWidth(rect) * scale, CGRectGetHeight(rect) * scale));
}

/// 对CGRect的x/y、width/height都调用一次flat，以保证像素对齐
CG_INLINE CGRect
CGRectFlatted(CGRect rect) {
    return CGRectMake(flat(rect.origin.x), flat(rect.origin.y), flat(rect.size.width), flat(rect.size.height));
}

/// 传入size，返回一个x/y为0的CGRect
CG_INLINE CGRect
CGRectMakeWithSize(CGSize size) {
    return CGRectMake(0, 0, size.width, size.height);
}

/// 判断一个 CGSize 是否合法（例如不带无穷大的值、不带非法数字）
CG_INLINE BOOL
CGSizeIsValidated(CGSize size) {
    return !CGSizeIsEmpty(size) && !CGSizeIsInf(size) && !CGSizeIsNaN(size);
}

/// 判断一个 CGSize 是否为空（宽或高为0）
CG_INLINE BOOL
CGSizeIsEmpty(CGSize size) {
    return size.width <= 0 || size.height <= 0;
}

/// 判断一个 CGSize 是否存在 infinite
CG_INLINE BOOL
CGSizeIsInf(CGSize size) {
    return isinf(size.width) || isinf(size.height);
}

/// 判断一个 CGSize 是否存在 NaN
CG_INLINE BOOL
CGSizeIsNaN(CGSize size) {
    return isnan(size.width) || isnan(size.height);
}

/**
 *  基于当前设备的屏幕倍数，对传进来的 floatValue 进行像素取整。
 *
 *  注意如果在 Core Graphic 绘图里使用时，要注意当前画布的倍数是否和设备屏幕倍数一致，若不一致，不可使用 flat() 函数，而应该用 flatSpecificScale
 */
CG_INLINE CGFloat
flat(CGFloat floatValue) {
    return flatSpecificScale(floatValue, 0);
}

CG_INLINE CGFloat
flatSpecificScale(CGFloat floatValue, CGFloat scale) {
    floatValue = removeFloatMin(floatValue);
    scale = scale ?: ([[UIScreen mainScreen] scale]);
    CGFloat flattedValue = ceil(floatValue * scale) / scale;
    return flattedValue;
}

/**
 *  某些地方可能会将 CGFLOAT_MIN 作为一个数值参与计算（但其实 CGFLOAT_MIN 更应该被视为一个标志位而不是数值），可能导致一些精度问题，所以提供这个方法快速将 CGFLOAT_MIN 转换为 0
 */
CG_INLINE CGFloat
removeFloatMin(CGFloat floatValue) {
    return floatValue == CGFLOAT_MIN ? 0 : floatValue;
}
@end
