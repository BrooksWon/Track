//
//  BTAppDelegate.m
//  Track
//
//  Created by BrooksWon on 07/15/2020.
//  Copyright (c) 2020 BrooksWon. All rights reserved.
//

#import "BTAppDelegate.h"
#import "BTViewController.h"
#import "BTLogStorage.h"

@implementation BTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *viewController = [[UINavigationController alloc] initWithRootViewController:[[BTViewController alloc] init]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[BTLogStorage shraed] popLog:^BOOL(NSData * _Nonnull log) {
//            
//            //网络上报
//            //        BOOL report = [NetEngin post:data];
//            NSString *result = [[NSString alloc] initWithData:log encoding:NSUTF8StringEncoding];
//            NSLog(@"log: %@", result);
//            return YES;
//        }];
//    });
    
    
    
    return YES;
}
- (void)testHello {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(testHello) object:nil];
    NSLog(@"hello");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
