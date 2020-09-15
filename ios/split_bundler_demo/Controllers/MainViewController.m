//
//  MainViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "MainViewController.h"

#import "RNBaseViewController.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width

@interface MainViewController ()
@property (nonatomic, strong) UIButton *jumpHomeBtn;
@property (nonatomic, strong) UIButton *jumpProfileBtn;
@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  
  [self initSubviews];
}

- (void)initSubviews {
  [self.view addSubview:self.jumpHomeBtn];
  [self.view addSubview:self.jumpProfileBtn];
  self.jumpHomeBtn.frame = CGRectMake(0, 200, SCREEN_W, 30);
  self.jumpProfileBtn.frame = CGRectMake(0, CGRectGetMaxY(self.jumpHomeBtn.frame) + 20, SCREEN_W, 30);
}

- (void)jumpAction:(UIButton *)button {
  NSInteger tag = button.tag;
  RNBaseViewController *rnVC = [[RNBaseViewController alloc] initWithInitialRouteName:nil launchOptions:nil];
  if (tag == 100) {
    [rnVC setupWithBundleName:BusinessBundleNameHome];
  } else if (tag == 110) {
    [rnVC setupWithBundleName:BusinessBundleNameProfile];
  }

  [self.navigationController pushViewController:rnVC animated:YES];
}

- (UIButton *)jumpHomeBtn {
  if (!_jumpHomeBtn) {
    _jumpHomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jumpHomeBtn setTitle:@"跳转到预加载的home业务" forState:UIControlStateNormal];
    [_jumpHomeBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _jumpHomeBtn.tag = 100;
    [_jumpHomeBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _jumpHomeBtn;
}

- (UIButton *)jumpProfileBtn {
  if (!_jumpProfileBtn) {
    _jumpProfileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jumpProfileBtn setTitle:@"跳转到无预加载的profile业务" forState:UIControlStateNormal];
    [_jumpProfileBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _jumpProfileBtn.tag = 110;
    [_jumpProfileBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _jumpProfileBtn;
}


@end
