//
//  AppDelegate.h
//  ZkDemo
//
//  Created by kui on 2020/9/22.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 判断是否允许屏幕旋转
@property (nonatomic,assign) BOOL allowRotation;

@end

