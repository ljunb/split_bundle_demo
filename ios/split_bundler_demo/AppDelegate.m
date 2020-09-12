#import "AppDelegate.h"

#import <React/RCTRootView.h>

#import "ReactNativeManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

  [[ReactNativeManager sharedManager] setupPreloadModules:^NSArray * _Nonnull{
    return @[@"home", @"index"];
  }];
  [[ReactNativeManager sharedManager] asyncLoadCommonBundleWithLaunchOptions:launchOptions complete:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupInitPage:) name:RNBundleLoadedNotification object:nil];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view.backgroundColor = UIColor.whiteColor;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)setupInitPage:(NSNotification *)notify {
  NSString *bundleName = [notify.userInfo objectForKey:@"bundle"];
  if (!bundleName || ![bundleName isEqualToString:@"index"]) {
    return;
  }
  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:[ReactNativeManager sharedManager].bridge moduleName:bundleName initialProperties:nil];
  self.window.rootViewController.view = rootView;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:RNBundleLoadedNotification object:nil];
}

@end
