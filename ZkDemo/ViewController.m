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
#import "TestVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (indexPath.row == 0) {
        SpinViewController *vc = [[SpinViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        ImageAveragingAlgorithmVC *vc = [[ImageAveragingAlgorithmVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2) {
        OpenCVImageAverageVC *vc = [[OpenCVImageAverageVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3) {
        OpenCVAddWatermarkVC *vc = [[OpenCVAddWatermarkVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        TestVC *vc = [[TestVC alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}






@end
