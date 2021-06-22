//
//  SpinViewController.m
//  ZkDemo
//
//  Created by kui on 2020/9/23.
//

#import "SpinViewController.h"

#import "AppDelegate.h"

@interface SpinViewController ()

/// yes竖屏
@property (nonatomic, assign) BOOL isPortrait;

@end

@implementation SpinViewController

{
    AppDelegate *appDelegate;
}

/**
 首先确认需要旋转的控制器是否有走以下两个方法
 - shouldAutorotate和supportedInterfaceOrientations确认是否正常执行。
 - 如果不走以上两个方法则是以下几种情况（因为被根控制器给接管了，所以根据自己的情况调整）
 - 1. NavigationController导航栏下的VC控制器，对于这种场景只需要在根导航栏里面添加以下代码即可
 - 2. TabbarController下的VC控制器，对于这种场景只需要在基类里面添加以下代码即可
 
 - 我这里只以NavigationController举例
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
     
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     
    appDelegate.allowRotation = YES;
     
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setOrientation:UIInterfaceOrientationLandscapeRight];
    });
    
}

#pragma mark--代码布局刷新(关于有人说旋转布局问题根据需求刷新即可)
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

#pragma mark--点击旋转
- (IBAction)clickSpinBtn:(id)sender {
    
    //获取屏幕方向进行旋转
    UIInterfaceOrientation oritentation = [[UIApplication sharedApplication] statusBarOrientation];
    int orientat;
    
    if (UIInterfaceOrientationIsPortrait(oritentation)) {
        self.isPortrait = NO;
        orientat = UIInterfaceOrientationLandscapeRight;
         
    }else{
        self.isPortrait = YES;
        orientat = UIInterfaceOrientationPortrait;
    }
    //进行旋转
    [self setOrientation:orientat];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    //退出页面设置竖屏(allowRotation 设置NO禁止旋转)
    [self setOrientation:UIInterfaceOrientationPortrait];
    appDelegate.allowRotation = NO;
}

/// 是否支持自动旋转
- (BOOL)shouldAutorotate {
    return YES;
}
  
/// 当设备旋转时.会走这里返回需要旋转的方向 (如AppDelegate.allowRotation设置UIInterfaceOrientationMaskPortrait 旋转的方向不支持时.触发旋转会闪退:)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
     
    //固定运行旋转的方向
    UIInterfaceOrientationMask screenMode;
    if (self.isPortrait) {
        NSLog(@"仅支持竖屏");
        screenMode = UIInterfaceOrientationMaskPortrait;
    }else {
        NSLog(@"运行旋转");
        screenMode = UIInterfaceOrientationMaskLandscapeRight;
    }
    return screenMode;
}
 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// 设置屏幕方向
/// @param orientation 方向
- (void)setOrientation:(int)orientation {
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}
 
- (void)dealloc {
    NSLog(@"SpinViewController");
}

@end
