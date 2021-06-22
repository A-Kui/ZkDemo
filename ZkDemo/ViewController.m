//
//  ViewController.m
//  ZkDemo
//
//  Created by kui on 2020/9/22.
//

#import "ViewController.h"
#import "SpinViewController.h"
#import "ImageAveragingAlgorithmVC.h"
#import "OpenCVImageAverageVC.h"
#import "OpenCVTestVC.h"
#import "OpenCVAddWatermarkVC.h"
#import "DiyCameraVC.h"

#import "TestVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    NSArray *arr = @[@"SpinViewController",@"ImageAveragingAlgorithmVC",
                     @"OpenCVImageAverageVC",@"OpenCVAddWatermarkVC",
                     @"DiyCameraVC",@"TestVC"];
    
    UIViewController *vc = [[NSClassFromString(arr[indexPath.row]) alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
  
}
 

@end
