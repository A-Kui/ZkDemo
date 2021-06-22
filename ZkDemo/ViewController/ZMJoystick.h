//
//  ZMJoystick.h
//  ZMJoystick
//
//  Created by 黄子鸿 on 2017/5/23.
//  Copyright © 2017年 黄子鸿. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReturnParameter) (NSUInteger vertical, NSUInteger horizontal);

@interface ZMJoystick : UIView

@property (nonatomic, assign) NSUInteger vertical;

@property (nonatomic, assign) NSUInteger horizontal;

+ (ZMJoystick *)joystick;

+ (ZMJoystick *)joystickWithFrame:(CGRect)frame;

@property (nonatomic, copy) ReturnParameter returnPar;

@end
