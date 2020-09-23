//
//  ZkNavigationController.m
//  ZkDemo
//
//  Created by kui on 2020/9/23.
//

#import "ZkNavigationController.h"

@interface ZkNavigationController ()

@end

@implementation ZkNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate{
    return [self.visibleViewController shouldAutorotate];
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return [self.visibleViewController supportedInterfaceOrientations];
//}

 

@end
