//
//  XMPPTool.h
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h" // 导入框架

typedef enum {
    XMPPResultTypeLoginSuccess, // 登陆成功
    XMPPResultTypeLoginFailure, // 登陆失败
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure // 注册失败
    
}XMPPResultType;

/**
 *  与服务器交互的结果的回调block
 *
 *  @param reslutType 结果类型
 */
typedef void (^XMPPResultBlock)(XMPPResultType reslutType);



@interface XMPPTool : NSObject

singleton_interface(XMPPTool)


/**
 *  与服务器交互的核心类 对象
 */
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

/**
 *  标识连接服务器时, 是登陆连接还是注册连接
 *  NO 代理登陆操作, YES 代表注册操作
 */
@property (nonatomic, assign, getter=isRegisterOperation) BOOL registerOperation;

// =================== 模块 ===========================================
/**
 *  电子名片模块
 */
@property (nonatomic, strong, readonly) XMPPvCardTempModule *vCard;
/**
 *  电子名片数据存储, 保存电子名片数据
 */
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *vCardStorage;

/**
 *  头像 模块
 */
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *avatar;

/**
 *  花名册 模块
 */
@property (nonatomic, strong, readonly) XMPPRoster *roster;
/**
 *  花名册 数据存储
 */
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *rosterStorage;


/**
 *  消息模块
 */
@property (nonatomic, strong, readonly)  XMPPMessageArchiving *message;
/**
 *  消息 数据存储
 */
@property (nonatomic, strong, readonly)  XMPPMessageArchivingCoreDataStorage *messageStorage;


// =================== 方法 ===========================================

/**
 *  xmpp登陆
 *
 *  @param resultBlock block 与服务器交互的结果
 */
-(void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  xmpp注册
 *
 *  @param resultBlock block 与服务器交互的结果
 */
-(void)xmppRegister:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
-(void)xmppLogout;

@end
