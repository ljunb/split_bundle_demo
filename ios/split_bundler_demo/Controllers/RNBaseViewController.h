//
//  RNBaseViewController.h
//  split_bundler_demo
//
//  Created by linjb on 2020/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNBaseViewController : UIViewController

@property (nonatomic, copy) NSString *initialRouteName;
@property (nonatomic, copy) NSDictionary *launchOptions;
@property (nonatomic, copy, readonly) NSDictionary *commonParams;

- (instancetype)initWithInitialRouteName:(NSString *)routeName launchOptions:(nullable NSDictionary *)launchOptions;

- (void)setupWithBundleName:(NSString *)bundleName;

@end

NS_ASSUME_NONNULL_END
