//
//  RNBundleLoader.h
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import <Foundation/Foundation.h>
@class RCTRootView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^LoadBundleCompletion)(NSError * _Nullable error);

@interface RNBundleLoader : NSObject
/**
 远程调试 bundle URL
 */
@property (nonatomic, strong, readonly) NSURL *remoteBundleURL;
/**
 基础 bundle URL
 */
@property (nonatomic, strong, readonly) NSURL *commonBundleURL;
/**
 预加载的bundle
 */
@property (nonatomic, copy) NSArray *preloadBundles;

/**
 加载业务bundle
 
 @param bundleName 业务模块名称
 @param launchOptions 初始化参数，可在此添加page名称
 @param sync 是否同步
 @param complete bundle加载结束回调
 */
- (void)loadBusinessBundleWithName:(NSString *)bundleName
                              sync:(BOOL)sync
                          complete:(nullable LoadBundleCompletion)complete;

- (void)updateRemoteBundleURL:(NSString *)bundleURL;

@end

NS_ASSUME_NONNULL_END
