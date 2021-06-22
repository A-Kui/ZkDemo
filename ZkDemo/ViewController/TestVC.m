//
//  TestVC.m
//  ZkDemo
//
//  Created by kui on 2021/6/21.
//

#import "TestVC.h"
#import "ZMJoystick.h"

@interface TestVC ()

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
 
    ZMJoystick *joystick2 = [ZMJoystick joystickWithFrame:CGRectMake(50, 150, 250, 250)];
    
    [joystick2 setReturnPar:^(NSUInteger vertical, NSUInteger horizontal){
  
//        NSLog(@"vertical:%lu --- horizontal:%lu",(unsigned long)vertical,(unsigned long)horizontal);
    }];
    
    [self.view addSubview:joystick2];
}


 
@end
