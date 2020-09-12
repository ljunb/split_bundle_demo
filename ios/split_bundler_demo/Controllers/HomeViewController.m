//
//  HomeViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "HomeViewController.h"
#import <React/RCTRootView.h>
#import "ReactNativeManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  RCTRootView *rctView = [[RCTRootView alloc] initWithBridge:[ReactNativeManager sharedManager].bridge
                                                  moduleName:@"home"
                                           initialProperties:nil];
  [self.view addSubview:rctView];
  rctView.frame = self.view.bounds;
}

@end
