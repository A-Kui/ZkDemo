//
//  OpenCVTestVC.m
//  ZkDemo
//
//  Created by kui on 2020/10/18.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
  
using namespace cv;
//using namespace std;

#import "OpenCVTestVC.h"
 

@interface OpenCVTestVC ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImageView *imageView2;

@end

@implementation OpenCVTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 2 / 3)];
    [self.view addSubview:_imageView];
    
    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 5, self.view.frame.size.width, self.view.frame.size.width * 2 / 3)];
    [self.view addSubview:_imageView2];
    
    Mat image, logo, mask;
    UIImage *img1 = [UIImage imageNamed:@"6.jpg"];
    UIImageToMat(img1, image);
    UIImage *img2 = [UIImage imageNamed:@"xmm.png"];
    UIImageToMat(img2, logo);
    UIImageToMat(img2, mask, 0);
//    cv::Size size;
//    size.width = 11;
//    size.height = 11;
    Mat imageROI;
    imageROI = image(cv::Rect(0, 0, logo.cols * 1, logo.rows * 1));
    logo.copyTo(imageROI, mask);
//    addWeighted(imageROI, 0.8, logo, 0.8, 0, imageROI);
    _imageView.image = MatToUIImage(image);
     
    
}
 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 2 / 3)];
    [self.view addSubview:_imageView];
    
    self.imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 5, self.view.frame.size.width, self.view.frame.size.width * 2 / 3)];
    [self.view addSubview:_imageView2];
    
    Mat mat, logo, mask;
    UIImage *img1 = [UIImage imageNamed:@"0JZ"];
    UIImageToMat(img1, mat);
    UIImage *img2 = [UIImage imageNamed:@"wazi"];
    UIImageToMat(img2, logo);
    UIImageToMat(img2, mask, 0);
    Mat imageROI;
    imageROI = mat(cv::Rect(1000, 1000, logo.cols, logo.rows)); // 这里是第二张图放到第一张图的位置 (x, y, logo.cols, logo.rows)
    logo.copyTo(imageROI, mask);
    _imageView.image = MatToUIImage(mat);
 
}

@end
