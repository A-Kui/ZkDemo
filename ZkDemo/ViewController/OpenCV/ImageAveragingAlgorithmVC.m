//
//  ImageAveragingAlgorithmVC.m
//  ZkDemo
//
//  Created by kui on 2020/10/9.
//

#import "ImageAveragingAlgorithmVC.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ImageAveragingAlgorithmVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewFirst;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewSecond;
@property (weak, nonatomic) IBOutlet UIImageView *imgSecond;

@end

@implementation ImageAveragingAlgorithmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //图片像素宽高CGRectMake(0, 0, 3840, 2160)
    self.title = @"图像平均算法-OC原生";
    
//    self.scrollViewFirst.frame = CGRectMake(0, 88, self.view.frame.size.width, 200);
//    self.scrollViewFirst.contentSize = self.scrollViewFirst.frame.size;
//    self.img.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
//    self.scrollViewFirst.delegate = self;
//    [self.scrollViewFirst setZoomScale:7];
//
//    self.scrollViewSecond.frame = CGRectMake(0, 88 + 200 + 10, self.view.frame.size.width, 200);
//    self.scrollViewSecond.contentSize = self.scrollViewFirst.frame.size;
//    self.imgSecond.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
//    self.scrollViewSecond.delegate = self;
//    [self.scrollViewSecond setZoomScale:7];
     
}
 
- (IBAction)clickAveragingAlgorithmBtn:(id)sender {
     
//    UIImage *image = [self imageAveragingAlgorithm];
//
//    //保存图片
//    if (image) {
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
//
//        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//            NSLog(@"success = %d, error = %@", success, error);
//        }];
//    }
//
//    self.imgSecond.image = image;
//    
//    [self.scrollViewFirst setContentOffset:CGPointMake(0, 0)];
//    [self.scrollViewSecond setContentOffset:CGPointMake(0, 0)];
}

#pragma mark --模拟器相册路径(建议使用电脑查看图片对比效果)
- (IBAction)clickBtn:(UIButton *)sender {
    
    NSLog(@"根据自己路径拼接:/Users/kui/Library/Developer/CoreSimulator/Devices/2DF8E272-96C6-4EB7-AE27-7D212EBC2279/data/Media/DCIM");
}

- (UIImage *)imageAveragingAlgorithm{
    
    CGImageRef imImage = [UIImage imageNamed:@"0JZ"].CGImage;
    CFDataRef mDataRef = CGDataProviderCopyData(CGImageGetDataProvider(imImage));
    CFIndex length = CFDataGetLength(mDataRef);
    
    UInt8 *mPixelBuf = (UInt8 *)CFDataGetBytePtr(mDataRef);
    
    NSMutableArray <NSValue *>*dataArr = [NSMutableArray array];
    
    for (int i = 0; i <= 14; i++) {
         @autoreleasepool {
            UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"%dJZ",i]];
            if (mg) {
                CFDataRef mDataRef = CGDataProviderCopyData(CGImageGetDataProvider(mg.CGImage));
                [dataArr addObject:[NSValue valueWithPointer:mDataRef]];
                mg = nil;
            }
        }
         
    }
    
    for(int i = 0;i < length; i += 4){

        int red = 0,green = 0,blue = 0;

        for (size_t k = 0; k < dataArr.count - 1; k++) {
 
            CFDataRef dataBuf = [dataArr[k] pointerValue];
            UInt8 *pixeBuf = (UInt8 *)CFDataGetBytePtr(dataBuf);

            red += pixeBuf[i];
            green += pixeBuf[i + 1];
            blue += pixeBuf[i + 2];
        }

        int r = red / dataArr.count;
        int g = green / dataArr.count;
        int b = blue / dataArr.count;

        mPixelBuf[i] = r;
        mPixelBuf[i+1] = g;
        mPixelBuf[i+2] = b;
    }
    
    for (size_t k = 0; k < dataArr.count - 1; k++) {

        CFDataRef dataBuf = [dataArr[k] pointerValue];
        CFRelease(dataBuf);
    }
    
    [dataArr removeAllObjects];
    
    CGContextRef ctx = CGBitmapContextCreate(mPixelBuf,
                                             CGImageGetWidth(imImage),
                                             CGImageGetHeight(imImage),
                                             CGImageGetBitsPerComponent(imImage),
                                             CGImageGetBytesPerRow(imImage),
                                             CGImageGetColorSpace(imImage),
                                             CGImageGetBitmapInfo(imImage)
                                             );
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(ctx);
    CGImageRelease(imImage);
    CGImageRelease(imageRef);
    CFRelease(mDataRef);
 
    return finalImage;
}

////代理方法，告诉ScrollView要缩放的是哪个视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
 
    if (scrollView == self.scrollViewFirst) {
        return self.img;
    }else {
        return self.imgSecond;
    }
    
}
  
//- (UIImage *)whiteBlackImage{
//
//    CGImageRef imImage = [UIImage imageNamed:@"0JZ"].CGImage;
//    CFDataRef mDataRef = CGDataProviderCopyData(CGImageGetDataProvider(imImage));
//    CFIndex length = CFDataGetLength(mDataRef);
//
//    UInt8 *mPixelBuf = (UInt8 *)CFDataGetBytePtr(mDataRef);
//
//    NSMutableArray <NSValue *>*dataArr = [NSMutableArray array];
//
//    for (int i = 0; i <= 14; i++) {
//         @autoreleasepool {
//            UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"%dJZ",i]];
//            if (mg) {
//                CFDataRef mDataRef = CGDataProviderCopyData(CGImageGetDataProvider(mg.CGImage));
//                UInt8 *pixeBuf = (UInt8 *)CFDataGetBytePtr(mDataRef);
//
//                [dataArr addObject:[NSValue valueWithPointer:pixeBuf]];
//                CFRelease(mDataRef);
////            NSLog(@"length:%ld",(long)length);
////                free(pixeBuf);
//            }
//        }
//
//    }
//
//    for(int i = 0;i < length; i += 4){
//
//        int red = 0,green = 0,blue = 0;
//
//        for (size_t k = 0; k < dataArr.count - 1; k++) {
//
//            UInt8 *pixeBuf = [dataArr[k] pointerValue];
//
//            red += pixeBuf[i];
//            green += pixeBuf[i + 1];
//            blue += pixeBuf[i + 2];
//        }
//
//        int r = red / dataArr.count;
//        int g = green / dataArr.count;
//        int b = blue / dataArr.count;
//
//        mPixelBuf[i] = r;
//        mPixelBuf[i+1] = g;
//        mPixelBuf[i+2] = b;
//    }
//
//    for (size_t k = 0; k < dataArr.count - 1; k++) {
//
//        UInt8 *pixeBuf = [dataArr[k] pointerValue];
//
//    }
//
//    CGContextRef ctx = CGBitmapContextCreate(mPixelBuf,
//                                             CGImageGetWidth(imImage),
//                                             CGImageGetHeight(imImage),
//                                             CGImageGetBitsPerComponent(imImage),
//                                             CGImageGetBytesPerRow(imImage),
//                                             CGImageGetColorSpace(imImage),
//                                             CGImageGetBitmapInfo(imImage)
//                                             );
//
//    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
//    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
//    CGContextRelease(ctx);
//    CGImageRelease(imageRef);
//    CFRelease(mDataRef);
//
//    return finalImage;
//}


  
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//   CGImageRef cgimage = [[UIImage imageNamed:@"SamplePictureZK0"] CGImage];
//
//   size_t width = CGImageGetWidth(cgimage); // 图片宽度
//
//   size_t height = CGImageGetHeight(cgimage); // 图片高度
//
//   unsigned char *data = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
//
//   size_t bitsPerComponent = 8; // r g b a 每个component bits数目
//
//   size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
//
//   CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间
//
//   CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//
//   CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
//
//   NSMutableArray <NSData *>*dataArr = [NSMutableArray array];
//
//   for (int i = 1; i <= 10; i++) {
//
//        UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"SamplePictureZK%d",i]];
////       UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"SamplePicture%d",i]];
//
//       if (mg) {
//           const char *bytes = [self getImgPixelMatrixWithImage:mg];
//           NSLog(@"i=%d---bytes长度:%lu",i,strlen(bytes));
//           [dataArr addObject:[NSData dataWithBytes:bytes length:strlen(bytes)]];
//       }
//
//   }
//
//   unsigned char *imgPixel = calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
//
//   for (size_t i = 0; i < height; i++)  {
//
//       for (size_t j = 0; j < width; j++) {
//
//           size_t row = i * width * 4;
//
//           size_t pixelIndex = row + (j * 4);
//
//           int red = 0,green = 0,blue = 0,alpha = 0;
//
////           if (pixelIndex > 7000000) {
////               NSLog(@"i:%zu--j:%zu",i,j);
////           }
//
//           for (size_t k = 0; k < dataArr.count; k++) {
//
//               unsigned const char *bytes = [dataArr[k] bytes];
//               /**使用48行的报错. 49行正常没问题.
//                为什么这里 k = 9 的时候 bytes[7553024]会越界.
//                而1-9 长度也会有越界不报错
//                i=1---bytes长度:6087361
//                i=2---bytes长度:1937257
//                i=3---bytes长度:1919937
//                i=4---bytes长度:2421025
//                i=5---bytes长度:4981149
//                i=6---bytes长度:1928593
//                i=7---bytes长度:3876481
//                i=8---bytes长度:753853
//                i=9---bytes长度:6078057
//                i=10---bytes长度:7549361
//                */
//               alpha += bytes[pixelIndex];
//               red += bytes[pixelIndex + 1];
//               green += bytes[pixelIndex + 2];
//               blue += bytes[pixelIndex + 3];
//           }
//
//           int a = alpha / dataArr.count;
//           int r = red / dataArr.count;
//           int g = green / dataArr.count;
//           int b = blue / dataArr.count;
//
//           // 赋值rgb通道
//           imgPixel[pixelIndex + 0] = a;
//           imgPixel[pixelIndex + 1] = r;
//           imgPixel[pixelIndex + 2] = g;
//           imgPixel[pixelIndex + 3] = b;
//       }
//   }
//
////    cgimage = CGBitmapContextCreateImage(context);
////
////    UIImage *img = [UIImage imageWithCGImage:cgimage];
//
//   //输出图片
//  CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, imgPixel, bytesPerRow * height, ProviderReleaseData);
//  CGImageRef imageRef = CGImageCreate(width, height, 8, 32, bytesPerRow, space,
//                                      kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
//                                      NULL, true, kCGRenderingIntentDefault);
//
//  CGDataProviderRelease(dataProvider);
//   UIImage *img = [UIImage imageWithCGImage:imageRef];
//   //保存图片
//   if (img) {
//       [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//
//           PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:img];
//
//       } completionHandler:^(BOOL success, NSError * _Nullable error) {
//           NSLog(@"success = %d, error = %@", success, error);
//       }];
//   }
//   NSLog(@"清理空间");
//  // end：清理空间
//  CGImageRelease(imageRef);
//  CGContextRelease(context);
//  CGColorSpaceRelease(space);
//
//   UIImageView *imgView = [[UIImageView alloc]initWithImage:img];
//   imgView.frame = self.view.bounds;
//   [self.view insertSubview:imgView atIndex:0];
//}
//
//- (char *)getImgPixelMatrixWithImage:(UIImage*)image {
//
//    const int imageWidth = image.size.width;
//    const int imageHeight = image.size.height;
//    size_t    bytesPerRow = imageWidth * 4;
//
//    char *rgbImageBuf = calloc(imageWidth * imageHeight * 4, sizeof(unsigned char)); // 取图片首地址
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    /**
//     data 指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
//     bitsPerComponent 内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
//     bitmap的每一行在内存所占的比特数
//     CGColorSpaceRef上下文使用的颜色空间。
//     指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
//     */
//    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
//                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//
//    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
//
//    return rgbImageBuf;
//}
//
////** 颜色变化 */
//void ProviderReleaseData (void *info, const void *data, size_t size){
//    free((void*)data);
//}
 
@end
