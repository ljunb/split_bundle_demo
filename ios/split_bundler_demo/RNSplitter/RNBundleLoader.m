//
//  RNBundleLoader.m
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import "RNBundleLoader.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge+Private.h>

#import "ReactNativeManager.h"


@interface RCTBridge (RNBundleLoader)
- (void)executeSourceCode:(NSData *)sourceCode sync:(BOOL)sync;
@end

@interface RNBundleLoader ()
/**
 已经加载过的bundle
 */
@property (nonatomic, strong) NSMutableArray *loadedBundle;
@end

@implementation RNBundleLoader

#pragma mark - Life cycle
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:RCTJavaScriptDidLoadNotification
                                                object:nil];
}

- (instancetype)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCommonBundleLoaded:)
                                                 name:RCTJavaScriptDidLoadNotification
                                               object:nil];
  }
  return self;
}

- (void)loadBusinessBundleWithName:(NSString *)bundleName
                              sync:(BOOL)sync
                          complete:(nullable LoadBundleCompletion)complete {
  
  if (!bundleName || bundleName.length == 0) {
    if (complete) {
      NSError *error = [NSError errorWithDomain:@"RNBundleLoadFailed" code:0 userInfo:nil];
      complete(error);
      return;
    }
  }
  
  [self loadBundleURLAtName:bundleName sync:sync complete:complete];
}

- (void)loadBundleURLAtName:(NSString *)bundleName
                       sync:(BOOL)sync
                   complete:(nullable LoadBundleCompletion)complete {
#if EnableRemoteDebug
  // 如果是远程调试，bundle name 设置为 common
  bundleName = CommonBundleName;
#else
#endif
  // 已经加载过了
  if ([self.loadedBundle containsObject:bundleName]) {
    if (complete) {
      // 预加载过的场景，这里需要返回一个view
      complete(nil);
    }
  } else {
    // 打缓存标记
    [self cacheLoadedBundle:bundleName];
    
    if (sync) {
      [self syncLoadBundleURLAtName:bundleName complete:complete];
    } else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self syncLoadBundleURLAtName:bundleName complete:complete];
      });
    }
  }
}

- (void)syncLoadBundleURLAtName:(NSString *)bundleName
                       complete:(nullable LoadBundleCompletion)complete {

  NSURL *bundleURL = [self bundleURLWithName:bundleName];
  NSAssert(bundleURL, @"加载bundle失败，bundleURL为nil");
  
  [RCTJavaScriptLoader loadBundleAtURL:bundleURL
                            onProgress:nil
                            onComplete:^(NSError *error, RCTSource *source) {
    if (!error && source.data) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [[ReactNativeManager sharedManager].bridge.batchedBridge executeSourceCode:source.data sync:YES];
        
        if (complete) {
          complete(nil);
        }
      });
    } else {
      if (complete) {
        complete(error);
      }
    }
  }];
}

- (void)updateRemoteBundleURL:(NSString *)bundleURL {
  if (!bundleURL) {
    return;
  }
  [[NSUserDefaults standardUserDefaults] setValue:bundleURL forKey:CustomRemoteURLCacheKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - RCTJavaScriptDidLoadNotification

- (void)onCommonBundleLoaded:(NSNotification *)notify {
#if EnableRemoteDebug
#else
  // 加载所有需要预加载的bundle
  [self loadAllPreloadBundles];
#endif
}

- (void)loadAllPreloadBundles {
  if (!self.preloadBundles || self.preloadBundles.count == 0) {
    return;
  }
  for (NSString *bundleName in self.preloadBundles) {
    [self loadBundleURLAtName:bundleName sync:NO complete:nil];
  }
}


#pragma mark - Private methods

- (void)cacheLoadedBundle:(NSString *)moduleName {
  if (!moduleName || moduleName.length == 0) {
    return;
  }
  @synchronized (self) {
    [self.loadedBundle addObject:moduleName];
  }
}

- (NSURL *)bundleURLWithName:(NSString *)moduleName {
  return [[NSBundle mainBundle] URLForResource:moduleName withExtension:@"bundle"];
}


#pragma mark - Getters

- (NSURL *)commonBundleURL {
#if EnableRemoteDebug
  NSURL *bundleURL = self.remoteBundleURL;
#else
  NSURL *bundleURL = [self bundleURLWithName:CommonBundleName];
#endif
  if (![self.loadedBundle containsObject:CommonBundleName]) {
    [self cacheLoadedBundle:CommonBundleName];
  }
  // 基础bundle的URL
  return bundleURL;
}

- (NSURL *)remoteBundleURL {
  NSString *result = [[NSUserDefaults standardUserDefaults] valueForKey:CustomRemoteURLCacheKey];
  if (!result) {
    return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
  }
  return [NSURL URLWithString:result];
}

- (NSMutableArray *)loadedBundle {
  if (!_loadedBundle) {
    _loadedBundle = [NSMutableArray array];
  }
  return _loadedBundle;
}

- (NSArray *)preloadBundles {
  if (!_preloadBundles) {
    _preloadBundles = [NSArray array];
  }
  return _preloadBundles;;
}

@end
