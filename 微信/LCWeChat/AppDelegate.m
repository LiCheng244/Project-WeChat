//
//  AppDelegate.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/17.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"
#import "DDLog.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //配置xmpp的日志启动
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    
    [self setupTheme];
    
    // 判断用户是否登陆过
    if ([LCAccount shareAccount].isLogin == YES) { // 登陆过, 主界面
        
        // 主界面
        id mainVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        self.window.rootViewController = mainVC;
        
        // 自动登陆
        [[XMPPTool sharedXMPPTool] xmppLogin:nil];
        
    }else{ // 没有登陆, 登陆界面
        
        id loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
        self.window.rootViewController = loginVC;
    }
    
    // 启动图片 延迟1.5秒
    [NSThread sleepForTimeInterval:1.5];


    return YES;
}

-(void)setupTheme{
    //设置导航条背景
    UINavigationBar *navBar = [UINavigationBar appearance];
    UIImage *image = [UIImage imageNamed:@"topbarbg_ios7"];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    // 设置全局状态栏样式
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置导航条标题字体样式
    NSMutableDictionary *titleAtt = [NSMutableDictionary dictionary];
    
    titleAtt[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
    titleAtt[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [navBar setTitleTextAttributes:titleAtt];
    
    // 返回按钮的样式 白色
    [navBar setTintColor:[UIColor whiteColor]];
    
    // 设置导航条item的样式
    NSMutableDictionary *itemAtt = [NSMutableDictionary dictionary];
    
    itemAtt[NSFontAttributeName] = [UIFont boldSystemFontOfSize:15];
    itemAtt[NSForegroundColorAttributeName] = [UIColor whiteColor];
    UIBarButtonItem *barItem = [UIBarButtonItem appearance];
    [barItem setTitleTextAttributes:itemAtt forState:UIControlStateNormal];
    
    
    
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
