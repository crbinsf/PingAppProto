//
//  AppDelegate.m
//  PingAppProto
//
//  Created by Clarke Bishop on 10/19/14.
//  Copyright (c) 2014 Clarke Bishop. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

#import "ViewController.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Parse connection
    [Parse setApplicationId:@"PkxSRxc92EU7i3NdeMfujJApy1dOyYMWv1Zzp2hs"
                  clientKey:@"KEkKPmakpIaoyKHmYSMjZFh0DnK3INBF5nspNH94"];
    
    // Analytics tracking - application opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    //CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // If user hasn't registered, take them to registration screen
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kRegisteredUserID] != nil) {
        // Take user directly to Map View
    } else {
        ViewController *rootController = [[ViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootController];
        window.rootViewController = navController;
    }
    
    [window makeKeyAndVisible];
    [self setWindow:window];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
