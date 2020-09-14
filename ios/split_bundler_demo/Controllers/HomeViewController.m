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
  
  [[ReactNativeManager sharedManager] setupRootViewWithBundleName:@"home"
                                                                           launchOptions:nil
                                                                                complete:^(RCTRootView * _Nullable rctView) {
    [self.view addSubview:rctView];
    rctView.frame = self.view.bounds;
  }];
}

@end
