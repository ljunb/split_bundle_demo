//
//  RNBaseViewController.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import "RNBaseViewController.h"

#import <React/RCTRootView.h>

#import "ReactNativeManager.h"

@interface RNBaseViewController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation RNBaseViewController

- (instancetype)initWithInitialRouteName:(nullable NSString *)routeName launchOptions:(nullable NSDictionary *)launchOptions {
  if (self = [super init]) {
    _initialRouteName = routeName;
    _launchOptions = launchOptions;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = UIColor.whiteColor;
  self.navigationController.delegate = self;
  [self initSubviews];
}

- (void)initSubviews {
  [self.view addSubview:self.placeholderLabel];
  self.placeholderLabel.frame = self.view.bounds;
}

- (void)setupWithBundleName:(NSString *)bundleName {
  
  if (!bundleName || bundleName.length == 0) {
    return;
  }
  
  // 增加公共参数
  NSMutableDictionary *extraInfo = [NSMutableDictionary dictionaryWithDictionary:self.commonParams];
  if (self.initialRouteName) {
    [extraInfo setObject:self.initialRouteName forKey:RNLaunchOptionsNameKeyInitialRoute];
  }
  if (self.launchOptions) {
    [extraInfo addEntriesFromDictionary:self.launchOptions];
  }
  
  [[ReactNativeManager sharedManager] setupRootViewWithBundleName:bundleName
                                                    launchOptions:extraInfo
                                                         complete:^(RCTRootView * _Nullable rctView) {
    if (!rctView) {
      self.placeholderLabel.hidden = NO;
      return;
    }

    [self.view addSubview:rctView];
    rctView.frame = self.view.bounds;
  }];
}

- (NSDictionary *)commonParams {
  return @{
    @"platform": @"ios",
    @"version": @"1.0.0",
  };
}

#pragma mark - NavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  BOOL isRNPage = [viewController isKindOfClass:[RNBaseViewController class]];
  [self.navigationController setNavigationBarHidden:isRNPage animated:YES];
}


- (UILabel *)placeholderLabel {
  if (!_placeholderLabel) {
    _placeholderLabel = ({
      UILabel *label = [UILabel new];
      label.text = @"加载RN页面失败";
      label.textColor = UIColor.redColor;
      label.font = [UIFont systemFontOfSize:14];
      label.textAlignment = NSTextAlignmentCenter;
      label.hidden = YES;
      label;
    });
  }
  return _placeholderLabel;
}

@end
