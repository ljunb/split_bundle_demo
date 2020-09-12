//
//  MainViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "IndexViewController.h"

#define SCREEN_W [UIScreen mainScreen].bounds.size.width

@interface MainViewController ()
@property (nonatomic, strong) UIButton *jumpHomeBtn;
@property (nonatomic, strong) UIButton *jumpProfileBtn;
@property (nonatomic, strong) UIButton *jumpIndexBtn;
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
// TODO：预加载基础bundle后，加载完整的未拆分bundle显示白屏
//  [self.view addSubview:self.jumpIndexBtn];
  self.jumpHomeBtn.frame = CGRectMake(0, 200, SCREEN_W, 30);
  self.jumpProfileBtn.frame = CGRectMake(0, CGRectGetMaxY(self.jumpHomeBtn.frame) + 20, SCREEN_W, 30);
  self.jumpIndexBtn.frame = CGRectMake(0, CGRectGetMaxY(self.jumpProfileBtn.frame) + 20, SCREEN_W, 30);
}

- (void)jumpAction:(UIButton *)button {
  NSInteger tag = button.tag;
  if (tag == 100) {
    [self.navigationController pushViewController:[HomeViewController new] animated:YES];
  } else if (tag == 110) {
    [self.navigationController pushViewController:[ProfileViewController new] animated:YES];
  } else if (tag == 120) {
    [self.navigationController pushViewController:[IndexViewController new] animated:YES];
  }
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

- (UIButton *)jumpIndexBtn {
  if (!_jumpIndexBtn) {
    _jumpIndexBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jumpIndexBtn setTitle:@"跳转到无拆包的index业务（完整bundle）" forState:UIControlStateNormal];
    [_jumpIndexBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    _jumpIndexBtn.tag = 120;
    [_jumpIndexBtn addTarget:self action:@selector(jumpAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _jumpIndexBtn;
}


@end
