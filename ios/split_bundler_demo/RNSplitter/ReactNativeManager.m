//
//  ReactNativeManager.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import "ReactNativeManager.h"
#import <React/RCTBridgeDelegate.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge+Private.h>


@interface RCTBridge (RNBundleLoader)
- (void)executeSourceCode:(NSData *)sourceCode sync:(BOOL)sync;
@end

@interface ReactNativeManager () <RCTBridgeDelegate>
/**
 已经加载过的bundle
 */
@property (nonatomic, strong) NSMutableArray *loadedBundle;
/**
 预加载的bundle
 */
@property (nonatomic, strong) NSMutableArray *preloadBundles;
@end

@implementation ReactNativeManager

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTJavaScriptDidLoadNotification object:nil];
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCommonBundleLoaded:)
                                                 name:RCTJavaScriptDidLoadNotification
                                               object:nil];
  }
  
  if (complete) {
    complete();
  }
}


- (void)setupRootViewWithBundleName:(NSString *)bundleName
                      launchOptions:(nullable NSDictionary *)launchOptions
                           complete:(SetupRootViewBlock)complete {
  [self loadBusinessBundleWithName:bundleName sync:YES launchOptions:launchOptions complete:complete];
}


- (void)setupPreloadModules:(NSArray * _Nonnull (^)(void))preModules {
  if (preModules) {
    NSArray *configModuels = preModules();
    if (configModuels) {
      self.preloadBundles = [NSMutableArray arrayWithArray:configModuels];
    }
  }
}


#pragma mark - RCTJavaScriptDidLoadNotification
- (void)onCommonBundleLoaded:(NSNotification *)notify {
  if (![self.loadedBundle containsObject:@"common"]) {
    [self cacheLoadedBundle:@"common"];
  }
  // 加载所有需要预加载的bundle
  [self loadAllPreloadBundles];
}

- (void)loadAllPreloadBundles {
  if (!self.preloadBundles || self.preloadBundles.count == 0) {
    return;
  }
  for (NSString *bundleName in self.preloadBundles) {
    [self loadBusinessBundleWithName:bundleName sync:NO launchOptions:self.launchOptions complete:nil];
  }
}


#pragma mark - RCTBridgeDelegate
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  // 基础bundle的URL
  return [self bundleURLWithName:@"common"];
}


#pragma mark - Private methods
- (void)loadBusinessBundleWithName:(NSString *)bundleName
                              sync:(BOOL)sync
                     launchOptions:(NSDictionary *)launchOptions
                          complete:(SetupRootViewBlock)complete {
  if (!bundleName || bundleName.length == 0) {
    return;
  }
  
  // 已加载过该 bundle
  if ([self.loadedBundle containsObject:bundleName]) {
    // 如果有结束回调，还是给个 RCTRootView 回去
    if (complete) {
      RCTRootView *rctView = [[RCTRootView alloc] initWithBridge:self.bridge
                                                      moduleName:bundleName
                                               initialProperties:launchOptions];
      complete(rctView);
    }
    return;
  }
  
  // 打上缓存标记
  [self cacheLoadedBundle:bundleName];
  
  // 同步加载
  if (sync) {
    [self loadBundleURLAtName:bundleName launchOptions:launchOptions complete:complete];
  } else {
    // 异步加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self loadBundleURLAtName:bundleName launchOptions:launchOptions complete:complete];
    });
  }
}

- (void)loadBundleURLAtName:(NSString *)bundleName
              launchOptions:(NSDictionary *)launchOptions
                   complete:(SetupRootViewBlock)complete{
  
  NSURL *bundleURL = [self bundleURLWithName:bundleName];
  NSAssert(bundleURL, @"加载bundle失败，bundleURL为nil");
  
  [RCTJavaScriptLoader loadBundleAtURL:bundleURL onProgress:nil onComplete:^(NSError *error, RCTSource *source) {
    if (!error && source.data) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.bridge.batchedBridge executeSourceCode:source.data sync:YES];
        // bundle加载完毕，新建 RCTRootView
        if (complete) {
          RCTRootView *rctView = [[RCTRootView alloc] initWithBridge:self.bridge
                                                          moduleName:bundleName
                                                   initialProperties:launchOptions];
          complete(rctView);
        }
      });
    } else {
      if (complete) {
        complete(nil);
      }
    }
  }];
}

- (NSURL *)bundleURLWithName:(NSString *)moduleName {
  return [[NSBundle mainBundle] URLForResource:moduleName withExtension:@"bundle"];
}

- (void)cacheLoadedBundle:(NSString *)moduleName {
  if (!moduleName || moduleName.length == 0) {
    return;
  }
  @synchronized (self) {
    [self.loadedBundle addObject:moduleName];
  }
}

#pragma mark - Getters
- (NSDictionary *)launchOptions {
  if (!_launchOptions) {
    _launchOptions = [NSDictionary dictionary];
  }
  return _launchOptions;
}

- (NSMutableArray *)loadedBundle {
  if (!_loadedBundle) {
    _loadedBundle = [NSMutableArray array];
  }
  return _loadedBundle;
}

- (NSMutableArray *)preloadBundles {
  if (!_preloadBundles) {
    _preloadBundles = [NSMutableArray array];
  }
  return _preloadBundles;;
}

@end
