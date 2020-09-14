//
//  ReactNativeManager.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "ReactNativeManager.h"

#import <React/RCTBridgeDelegate.h>
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import <React/RCTDevLoadingView.h>

#import "RNBundleLoader.h"

@interface ReactNativeManager () <RCTBridgeDelegate>
/**
 bundle加载管理类
 */
@property (nonatomic, strong) RNBundleLoader *bundleLoader;
@end

@implementation ReactNativeManager

+ (instancetype)sharedManager {
  static ReactNativeManager *manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[ReactNativeManager alloc] init];
  });
  return manager;
}

- (void)asyncLoadCommonBundle {
  [self asyncLoadCommonBundleWithLaunchOptions:nil complete:nil];
}

- (void)asyncLoadCommonBundleWithLaunchOptions:(nullable NSDictionary *)launchOptions
                                      complete:(nullable void(^)(void))complete {
  
  self.launchOptions = launchOptions;
  if (!_bridge) {
    _bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  }
  
  if (complete) {
    complete();
  }
}

- (void)setupRootViewWithBundleName:(NSString *)bundleName
                      launchOptions:(nullable NSDictionary *)launchOptions
                           complete:(SetupRootViewBlock)complete {
  
  __weak typeof(self) weakSelf = self;
  [self.bundleLoader loadBusinessBundleWithName:bundleName
                                           sync:YES
                                       complete:^(NSError * _Nullable error) {
    if (complete) {
      // 加载bundle出错
      if (error) {
        complete(nil);
      } else {
        RCTRootView *rctView = [[RCTRootView alloc] initWithBridge:weakSelf.bridge
                                                        moduleName:bundleName
                                                 initialProperties:launchOptions];
        complete(rctView);
      }
    }
  }];
}

- (void)setupPreloadBundles:(NSArray *)preBundles {
#if EnableRemoteDebug
#else
  if (!preBundles || preBundles.count == 0) {
    return;
  }
  self.bundleLoader.preloadBundles = preBundles;
#endif
}


#pragma mark - RCTBridgeDelegate
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return self.bundleLoader.commonBundleURL;
}


#pragma mark - Getters
- (NSDictionary *)launchOptions {
  if (!_launchOptions) {
    _launchOptions = [NSDictionary dictionary];
  }
  return _launchOptions;
}

- (RNBundleLoader *)bundleLoader {
  if (!_bundleLoader) {
    _bundleLoader = [[RNBundleLoader alloc] init];
  }
  return _bundleLoader;
}

@end
