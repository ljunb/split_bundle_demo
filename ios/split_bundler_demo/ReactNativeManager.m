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
@property (nonatomic, strong) NSMutableArray *loadedBundle;
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

- (void)asyncLoadCommonBundleWithLaunchOptions:(NSDictionary *)launchOptions complete:(void (^)(void))complete {
  
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

- (RCTRootView *)rootViewWithBundleName:(NSString *)bundleName launchOptions:(NSDictionary *)launchOptions {
  if (!bundleName || bundleName.length == 0) {
    return nil;
  }
  
  [self loadBusinessBundleWithName:bundleName sync:YES];
  return nil;
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
  [self cacheLoadedBundle:@"common"];
  [self loadAllPreloadBundles];
}

- (void)loadAllPreloadBundles {
  if (!self.preloadBundles || self.preloadBundles.count == 0) {
    return;
  }
  for (NSString *bundleName in self.preloadBundles) {
    [self loadBusinessBundleWithName:bundleName sync:NO];
  }
}

#pragma mark - RCTBridgeDelegate
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [self bundleURLWithName:@"common"];
}

#pragma mark - Private methods
- (void)loadBusinessBundleWithName:(NSString *)bundleName sync:(BOOL)sync {
  if (!bundleName || bundleName.length == 0) {
    return;
  }
  
  // 已加载过该 bundle
  if ([self.loadedBundle containsObject:bundleName]) {
    return;
  }
  
  [self cacheLoadedBundle:bundleName];
  
  // 同步加载
  if (sync) {
    [self syncLoadBusinessBundleWithName:bundleName];
  } else {
    // 异步加载
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [self syncLoadBusinessBundleWithName:bundleName];
    });
  }
}

- (void)syncLoadBusinessBundleWithName:(NSString *)bundleName {
  
  NSURL *bundleURL = [self bundleURLWithName:bundleName];
  NSAssert(bundleURL, @"加载bundle失败，bundleURL为nil");
  
  [RCTJavaScriptLoader loadBundleAtURL:bundleURL onProgress:nil onComplete:^(NSError *error, RCTSource *source) {
    
    if (!error && source.data) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.bridge.batchedBridge executeSourceCode:source.data sync:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RNBundleLoadedNotification object:nil userInfo:@{@"bundle":bundleName}];
      });
    } else {
      
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
