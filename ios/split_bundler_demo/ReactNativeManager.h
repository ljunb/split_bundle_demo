//
//  ReactNativeManager.h
//  split_bundler_demo
//
//  Created by linjb on 2020/9/12.
//

#import <Foundation/Foundation.h>
@class RCTBridge;
@class RCTRootView;

NS_ASSUME_NONNULL_BEGIN

#define RNBundleLoadedNotification @"RNBundleLoadedNotification"

@interface ReactNativeManager : NSObject

@property (nonatomic, strong) RCTBridge *bridge;
@property (nonatomic, strong) NSDictionary *launchOptions;

@property (nonatomic, strong) NSArray *preloadViews;

+ (instancetype)sharedManager;

- (void)asyncLoadCommonBundleWithLaunchOptions:(NSDictionary *)launchOptions
                                      complete:(void(^)(void))complete;

- (RCTRootView *)rootViewWithBundleName:(NSString *)bundleName
                          launchOptions:(NSDictionary *)launchOptions;

- (void)setupPreloadModules:(NSArray *(^)(void))preModules;

@end

NS_ASSUME_NONNULL_END
