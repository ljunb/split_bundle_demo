//
//  IndexViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "IndexViewController.h"
#import <React/RCTRootView.h>
#import "ReactNativeManager.h"

@interface IndexViewController ()

@end

@implementation IndexViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  [[ReactNativeManager sharedManager] setupRootViewWithBundleName:@"index"
                                                    launchOptions:nil
                                                         complete:^(RCTRootView * _Nullable rctView) {
    [self.view addSubview:rctView];
    rctView.frame = self.view.bounds;
  }];
}

@end
