//
//  AppDelegate.m
//  GRichTextDisplayView
//
//  Created by Caoguo on 2019/6/28.
//  Copyright © 2019 Namegold. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIViewController *currentViewController = [self topViewController:window];
    if (!window) {
        currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL rotateSelector = NSSelectorFromString(@"canAutoRotate");
    if ([currentViewController respondsToSelector:rotateSelector]) {
        NSMethodSignature *signature = [currentViewController methodSignatureForSelector:rotateSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:rotateSelector];
        [invocation setTarget:currentViewController];
        [invocation invoke];
        BOOL canAutorotate = NO;
        [invocation getReturnValue:&canAutorotate];
        if (canAutorotate) {
            SEL supportedOrientationsSelector = NSSelectorFromString(@"currentSupportedInterfaceOrientations");
            if ([currentViewController respondsToSelector:supportedOrientationsSelector]) {
                NSMethodSignature *signatureInterface = [currentViewController methodSignatureForSelector:supportedOrientationsSelector];
                NSInvocation *invocationInterface = [NSInvocation invocationWithMethodSignature:signatureInterface];
                [invocationInterface setSelector:supportedOrientationsSelector];
                [invocationInterface setTarget:currentViewController];
                [invocationInterface invoke];
                //返回值长度
                NSUInteger length = [signatureInterface methodReturnLength];
                //根据长度申请内存
                void *buffer = (void *)malloc(length);
                //为变量赋值
                [invocationInterface getReturnValue:buffer];
                return [[NSNumber numberWithInteger:*((NSInteger*)buffer)] integerValue];
                
            } else {
                return UIInterfaceOrientationMaskAllButUpsideDown;
            }
        }
    }
#pragma clang diagnostic pop
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)topViewController:(UIWindow *)window {
    return [self topViewControllerWithRootViewController:window.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


@end
