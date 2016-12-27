//
//  LCAccount.h
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

/**
 *  账户模型
 */
#import <Foundation/Foundation.h>

@interface LCAccount : NSObject
/**
 *  登陆的用户名
 */
@property (nonatomic, strong) NSString *loginUserName;
/**
 *  登陆的密码
 */
@property (nonatomic, strong) NSString *loginPwd;
/**
 *  判断用户是否登陆
 */
@property (nonatomic, assign, getter=isLogin) BOOL login;


/**
 *  注册的用户名
 */
@property (nonatomic, strong) NSString *registerUserName;
/**
 *  注册的密码
 */
@property (nonatomic, strong) NSString *registerPwd;


/**
 *  服务器的域名
 */
@property (nonatomic, strong, readonly) NSString *domain;
/**
 *  服务器的IP
 */
@property (nonatomic, strong, readonly) NSString *host;
/**
 *  服务器的端口号
 */
@property (nonatomic, assign, readonly) NSInteger hostPort;


/**
 *  单例方法
 */
+(instancetype)shareAccount;

/**
 *  保存最新用户数据到沙盒中
 */
-(void)saveToSandBox;
@end
