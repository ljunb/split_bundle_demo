//
//  RNRouteManager.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import "RNRouteManager.h"

#import <UIKit/UIKit.h>

#import "RNBaseViewController.h"

@interface UIWindow (Visible)
+ (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc;
@end

@implementation UIWindow (Visible)
+ (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)vc {
  if ([vc isKindOfClass:[UINavigationController class]]) {
    return [UIWindow getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
  } else if ([vc isKindOfClass:[UITabBarController class]]) {
    return [UIWindow getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
  } else {
    if (vc.presentedViewController) {
      return [UIWindow getVisibleViewControllerFrom:vc.presentedViewController];
    } else {
      return vc;
    }
  }
}
@end

@interface RNRouteManager ()
@property (nonatomic, strong) NSDictionary *bundleMap;
@end

@implementation RNRouteManager

RCT_EXPORT_MODULE()

- (instancetype)init {
  if (self = [super init]) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BundleRoutesMap" ofType:@"plist"];
    self.bundleMap = [[NSDictionary alloc] initWithContentsOfFile:path];
  }
  return self;
}

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(pop) {
  UIViewController *rootViewController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
  UIViewController *topVC = [UIWindow getVisibleViewControllerFrom:rootViewController];
  if ([topVC isKindOfClass:[RNBaseViewController class]]) {
    [topVC.navigationController popViewControllerAnimated:YES];
  }
}

RCT_EXPORT_METHOD(navigate:(NSString *)pageName params:(NSDictionary *)params) {
  NSString *bundleName = [self.bundleMap objectForKey:pageName];
  NSAssert(bundleName, @"该页面没有注册到对应bundle路由中");
  
  RNBaseViewController *rnVC = [[RNBaseViewController alloc] initWithInitialRouteName:pageName
                                                                        launchOptions:params];
  [rnVC setupWithBundleName:bundleName];
  
  UIViewController *rootViewController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
  UIViewController *topVC = [UIWindow getVisibleViewControllerFrom:rootViewController];
  [topVC.navigationController pushViewController:rnVC animated:YES];
}


@end
