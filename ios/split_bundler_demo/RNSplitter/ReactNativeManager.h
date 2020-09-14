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

typedef void(^SetupRootViewBlock)(RCTRootView * _Nullable rctView);

@interface ReactNativeManager : NSObject

/**
 全局唯一的bridge
 */
@property (nonatomic, strong) RCTBridge *bridge;
/**
 启动初始参数
 */
@property (nonatomic, strong) NSDictionary *launchOptions;

+ (instancetype)sharedManager;

/**
 异步加载基础包
 */
- (void)asyncLoadCommonBundle;
- (void)asyncLoadCommonBundleWithLaunchOptions:(nullable NSDictionary *)launchOptions
                                      complete:(nullable void(^)(void))complete;

/**
 创建某个业务bundle下的RCTRootView
 
 该方法将会回调一个创建好的 RCTRootView：
 1、如果该 bundle 已经加载过，则直接基于单例 bridge 创建新的 RCTRootView，比如预加载场景；
 2、如果没有预加载，则先加载该业务 bundle，在加载结束回调中创建新的 RCTRootView
 
 @param bundleName 业务模块名称
 @param launchOptions 初始化参数，可在此添加page名称
 @param complete bundle加载结束回调
*/
- (void)setupRootViewWithBundleName:(NSString *)bundleName
                      launchOptions:(nullable NSDictionary *)launchOptions
                           complete:(SetupRootViewBlock)complete;

/**
 设置需要预加载的模块
 */
- (void)setupPreloadBundles:(NSArray *)preBundles;

@end

NS_ASSUME_NONNULL_END
