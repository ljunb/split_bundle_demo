#import "AppDelegate.h"

#import <React/RCTRootView.h>

#import "ReactNativeManager.h"
#import "MainViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

  [[ReactNativeManager sharedManager] setupPreloadModules:^NSArray * _Nonnull{
    return @[@"home"];
  }];
  [[ReactNativeManager sharedManager] asyncLoadCommonBundle];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  MainViewController *rootViewController = [MainViewController new];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootViewController];
  self.window.rootViewController = nav;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
