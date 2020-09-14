//
//  RNRouteManager.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import "RNRouteManager.h"

#import <UIKit/UIKit.h>

#import "RNBaseViewController.h"
#import "HomeViewController.h"

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

@implementation RNRouteManager

RCT_EXPORT_MODULE()

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
  if (!pageName || pageName.length == 0) {
    return;
  }
  
  // todo: mapping module name to bundle
  if ([pageName isEqualToString:@"Detail"]) {
    HomeViewController *homeVC = [[HomeViewController alloc] initWithInitialRouteName:pageName
                                                                        launchOptions:params];
    
    UIViewController *rootViewController =[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIViewController *topVC = [UIWindow getVisibleViewControllerFrom:rootViewController];
    [topVC.navigationController pushViewController:homeVC animated:YES];
  }
}


@end
