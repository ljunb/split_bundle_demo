//
//  MainViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "MainViewController.h"

#import "RNBaseViewController.h"
#import "ReactNativeManager.h"
#import "RNBundleLoader.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width

@interface MainViewController ()
@property (nonatomic, strong) UIButton *jumpHomeBtn;
@property (nonatomic, strong) UIButton *jumpProfileBtn;
@property (nonatomic, strong) UITextView *bundleURLField;
@property (nonatomic, strong) UIButton *saveURLBtn;
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
  [self.view addSubview:self.bundleURLField];
  [self.view addSubview:self.saveURLBtn];
  self.jumpHomeBtn.frame = CGRectMake(0, 200, SCREEN_W, 30);
  self.jumpProfileBtn.frame = CGRectMake(0, CGRectGetMaxY(self.jumpHomeBtn.frame) + 20, SCREEN_W, 30);
  self.bundleURLField.frame = CGRectMake(20, CGRectGetMaxY(self.jumpProfileBtn.frame) + 30, SCREEN_W - 40, 60);
  self.saveURLBtn.frame = CGRectMake(0, 0, 80, 30);
  self.saveURLBtn.center = CGPointMake(CGRectGetMidX(self.bundleURLField.frame), CGRectGetMaxY(self.bundleURLField.frame) + 30);
  
  self.bundleURLField.text = [ReactNativeManager sharedManager].bundleLoader.remoteBundleURL.absoluteString;
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

- (void)saveAction {
  NSAssert(self.bundleURLField.text, @"URL不能为nil");
  [[ReactNativeManager sharedManager].bundleLoader updateRemoteBundleURL:self.bundleURLField.text];
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

- (UITextView *)bundleURLField {
  if (!_bundleURLField) {
    _bundleURLField = [[UITextView alloc] init];
    _bundleURLField.font = [UIFont systemFontOfSize:14];
    _bundleURLField.layer.borderWidth = 0.5;
  }
  return _bundleURLField;
}

- (UIButton *)saveURLBtn {
  if (!_saveURLBtn) {
    _saveURLBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveURLBtn setTitle:@"Save" forState:UIControlStateNormal];
    [_saveURLBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_saveURLBtn setBackgroundColor:UIColor.blueColor];
    _saveURLBtn.layer.cornerRadius = 4;
    [_saveURLBtn addTarget:self action:@selector(saveAction) forControlEvents:UIControlEventTouchUpInside];
  }
  return _saveURLBtn;
}

@end
