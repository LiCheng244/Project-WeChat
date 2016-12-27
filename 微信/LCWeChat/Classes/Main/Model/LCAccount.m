//
//  LCAccount.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCAccount.h"


static NSString *domain = @"licheng.local";
static NSString *host = @"127.0.0.1";
static NSInteger hostPort = 5222;


@implementation LCAccount


+(instancetype)shareAccount
{
    return [[self alloc] init];
}

/**
 *  分配内存创建对象, 不管用如何方法创建都调用这个方法
 */
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    NSLog(@"%s",__func__);
    
    //写一个单例, 为了线程安全

    static LCAccount *account;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (account == nil) {
            
            account = [super allocWithZone:zone];
            
            // 从沙盒中获取上次的登陆信息
            account.loginUserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginUserName"];
            account.loginPwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginPwd"];
            account.login = [[NSUserDefaults standardUserDefaults] boolForKey:@"login"];
        }
    });
    
    return account;
}

-(void)saveToSandBox
{
    NSUserDefaults *userD = [NSUserDefaults standardUserDefaults];
    
    // 保存用户名
    [userD setObject:self.loginUserName forKey:@"loginUserName"];
    //密码
    [userD setObject:self.loginPwd forKey:@"loginPwd"];
    
    //登陆状态
    [userD setBool:self.isLogin forKey:@"login"];
    
    // 同步到磁盘
    [userD synchronize];
}

-(NSString *)domain
{
    return domain;
}
-(NSString *)host
{
    return host;
}
-(NSInteger)hostPort
{
    return hostPort;
}
@end
