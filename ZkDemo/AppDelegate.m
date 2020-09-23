//
//  AppDelegate.m
//  ZkDemo
//
//  Created by kui on 2020/9/22.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        //NSLog(@"AppDelegate---支持旋转");
        return UIInterfaceOrientationMaskAll;
    }else{
        //NSLog(@"AppDelegate---仅支持竖屏");
        return UIInterfaceOrientationMaskPortrait;
    }
}
  
@end
