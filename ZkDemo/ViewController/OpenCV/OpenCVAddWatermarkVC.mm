//
//  OpenCVAddWatermarkVC.m
//  ZkDemo
//
//  Created by kui on 2020/10/18.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

#import "OpenCVAddWatermarkVC.h"

using namespace cv;

@interface OpenCVAddWatermarkVC ()

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@end

@implementation OpenCVAddWatermarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.slider addTarget:self action:@selector(triggerSlider:) forControlEvents:UIControlEventValueChanged];
}

- (void)triggerSlider:(UISlider *)slider {
   
    Mat mat, inputMat, imageROI, mask,test;
    UIImage *img = [UIImage imageNamed:@"lufei"];
    UIImageToMat(img, mat);
    UIImageToMat(img, test);
    UIImage *hamburgerImg = [UIImage imageNamed:@"hamburger"];
    UIImageToMat(hamburgerImg, inputMat);
    UIImageToMat(hamburgerImg, mask, 0);
    
    imageROI = mat(cv::Rect(0, 0, mask.cols, mask.rows));
    inputMat.copyTo(imageROI, mask);
    
    UIImage *mg = MatToUIImage(mat);
    UIImage *mg1 = MatToUIImage(inputMat);
    UIImage *mg2 = MatToUIImage(imageROI);
    UIImage *mg3 = MatToUIImage(mask);
    
    addWeighted(test, 1, mat, 0.3, 0, test);
    
    
    self.img.image = MatToUIImage(test);
    
}
//Mat mat, logo, mask;
//UIImage *img1 = [UIImage imageNamed:@"0JZ"];
//UIImageToMat(img1, mat);
//UIImage *img2 = [UIImage imageNamed:@"wazi"];
//UIImageToMat(img2, logo);
//UIImageToMat(img2, mask, 0);
//Mat imageROI;
//imageROI = mat(cv::Rect(1000, 1000, logo.cols, logo.rows)); // 这里是第二张图放到第一张图的位置 (x, y, logo.cols, logo.rows)
//logo.copyTo(imageROI, mask);
//_imageView.image = MatToUIImage(mat);

@end
