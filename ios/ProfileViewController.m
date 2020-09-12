//
//  ProfileViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "ProfileViewController.h"
#import <React/RCTRootView.h>
#import "ReactNativeManager.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  [[ReactNativeManager sharedManager] setupRootViewWithBundleName:@"profile"
                                                    launchOptions:nil
                                                         complete:^(RCTRootView * _Nonnull rctView) {
    [self.view addSubview:rctView];
    rctView.frame = self.view.bounds;
  }];
  
}


@end
