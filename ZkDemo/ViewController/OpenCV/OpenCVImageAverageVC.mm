//
//  OpenCVImageAverageVC.m
//  ZkDemo
//
//  Created by kui on 2020/10/15.
//
//    //前四参数:前mat对象.后面权重 -----参数5:gamma 设置0 参数6:接受mat
//    addWeighted(mat0, 0.5, mat1, 0.5, 1, mat2);

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVImageAverageVC.h"

using namespace cv;

@interface OpenCVImageAverageVC ()

@end

@implementation OpenCVImageAverageVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
  
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
     
//    Mat mat;
//    UIImage *mg = [UIImage imageNamed:@"0JZ"];
//    UIImageToMat(mg, mat);
//    
//    CGFloat alphaWeights = 0;
//    CGFloat betaWeights = 0;
//    
//    for (int i = 1; i <= 14; i++) {
//
//        UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"%dJZ",i]];
//        Mat inputMat;
//
//        UIImageToMat(mg, inputMat);
//
//        alphaWeights = alphaWeights + 0.066;
//
//        betaWeights = 1 - alphaWeights;
//
//        addWeighted(mat, alphaWeights, inputMat, betaWeights, 0, mat);
//    }
//    
//    UIImage *img = MatToUIImage(mat);
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 1; i <= 14; i++) {
        
        UIImage *mg = [UIImage imageNamed:[NSString stringWithFormat:@"%dJZ",i]];
         
        [arr addObject:mg];
    }
     
    UIImage *img = [self imageDenoising:arr];
    NSLog(@"%@",img);
}

- (UIImage *)imageDenoising:(NSMutableArray *)imageArr {
    Mat mat;
    UIImage *mg = imageArr.firstObject;
    UIImageToMat(mg, mat);
    
    CGFloat alphaWeights = 0;
    CGFloat betaWeights = 0;
    
    for (int i = 1; i < imageArr.count; i++) {
        NSLog(@"aa");
        UIImage *mg = imageArr[i];
        Mat inputMat;
        
        UIImageToMat(mg, inputMat);
        
        alphaWeights = alphaWeights + 0.066;
        
        betaWeights = 1 - alphaWeights;
        
        addWeighted(mat, alphaWeights, inputMat, betaWeights, 0, mat);
    }
    
    UIImage *img = MatToUIImage(mat);
    return img;
}
 
@end
