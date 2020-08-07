//
//  AppDelegate.m
//  SearchCity
//
//  Created by 曹海洋 on 2020/8/6.
//  Copyright © 2020 . All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HYSearchCityViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // ViewController类可一步步将原始数据转化为最终要使用的格式
//    _window.rootViewController = [[ViewController alloc] init];
    
    // HYSearchCityViewController类是成品的城市搜索页
    _window.rootViewController = [[HYSearchCityViewController alloc] init];
    [_window makeKeyAndVisible];
    
    return YES;
}



@end
