//
//  XMPPTool.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "XMPPTool.h"

@interface XMPPTool()<XMPPStreamDelegate>
// 全局变量
{
    XMPPResultBlock _resultBlock; // 登陆服务器结果的回调block
}

@end

@implementation XMPPTool

singleton_implementation(XMPPTool)


//**********************************************************************
#pragma mark - 公共方法
#pragma mark -- 用户登录
-(void)xmppLogin:(XMPPResultBlock)resultBlock
{
    /**
     *  登陆流程:
        
        1. 初始化 XMPPStream
        2. 建立连接到服务器(要传一个jid)
        3. 连接成功后, 发送密码(在代理方法中调用)
        4. 连接成功后, 要发送一个 "在线" 给服务器(默认登陆成功后,是不在线的)(在代理方法中调用)
            -> 好处:可以通知其他好友,上线了
     */
    
    // 保存block
    _resultBlock = resultBlock;
 
    // 将以前的连接断开重新连接, 否则会报错, 说 已经有该连接, 不能再连接
    [_xmppStream disconnect];
    
    // 建立连接到服务器(要传一个jid)
    [self connectToHost];
}

#pragma mark -- 用户注册
-(void)xmppRegister:(XMPPResultBlock)resultBlock
{
    LCLog(@"zhuc 1111111111");
    /**
     *  注册流程:
        
        1. 发送注册的 jid 给服务器, 建立一个长连接
        2. 连接成功后, 发送注册密码(代理方法中实现)
     */
    
    // 保存block
    _resultBlock = resultBlock;

    // 删除连接
    [_xmppStream disconnect];
    
    // 发送注册的 jid 给服务器, 建立一个长连接
    [self connectToHost];
}

#pragma mark -- 用户注销
-(void)xmppLogout
{
    //注销流程:
    
    // 1. 发送"离线消息" 给服务器
    [self sendOffline];
    
    // 2. 断开与服务器的连接
    [self disconncetFromHost];
}


//**********************************************************************
#pragma mark - 私有方法
#pragma mark --登陆,注册
#pragma mark -- 1.初始化 xmppStream 对象
-(void)setUpStream
{
    // 创建
    _xmppStream = [[XMPPStream alloc] init];
    
    // 设置代理
    // 因为是全局队列 所有的代理方法都将在子线程中调用
    [_xmppStream addDelegate:self delegateQueue:(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))];

    
    // 添加xmpp模块
    
    // 1.添加电子名片模块  对象0054 (该模块一般还会配合 头像模块 一起使用)
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //  激活
    [_vCard activate:_xmppStream];
    
    // 2.添加头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    // 激活
    [_avatar activate:_xmppStream];
    
    // 3.添加花名册模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    // 激活
    [_roster activate:_xmppStream];
    
    // 4.添加消息模块
    _messageStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _message = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_messageStorage];
    // 激活
    [_message activate:_xmppStream];
    
    
}
#pragma mark -- 2.连接服务器
-(void)connectToHost
{
    
    /**
     *  连接服务器流程:
     
     1. 设置jid
        1> 判断 连接 是登陆 还是注册
        2> 从单例中获取用户名
        3> 拼接jid  jidWithUser
        4> 设置jid
     2. 设置主机地址
     3. 设置主机端口号(不设置的话,默认是5222)
     4. 发起连接
     */
    
    /**
     *  注意: 不管用户名存不存在, 连接服务器都会成功,
     
     1. 如果用户存在,密码正确  会调用xmppStreamDidAuthenticate
     2. 如果用户名不存在 会调用-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
     */
    
    
    // 初始化 XMPPStream
    if (_xmppStream == nil) {
        [self setUpStream];
    }

    //1. 设置jid
    
    XMPPJID *myJid = nil;
    LCAccount *account = [LCAccount shareAccount]; // 账户对象
    
    // 1> 判断 连接是登陆还是注册
    if (self.isRegisterOperation) { // 注册
        
        // 2> 从单例中获取用户名
        NSString *registerUser = account.registerUserName;
        // 3> 拼接jid  resource: 用户用于登陆客户端的设备类型
        myJid = [XMPPJID jidWithUser:registerUser domain:account.domain resource:@"iphone"];
        
    }else{ // 登陆
        
        NSString *loginUser = account.loginUserName;
        myJid = [XMPPJID jidWithUser:loginUser domain:account.domain resource:@"iphone"];
    }
    // 4> 设置
    _xmppStream.myJID = myJid;
    
    
    //2.设置主机地址
    _xmppStream.hostName = account.host;
    
    //3.设置主机端口号(不设置的话,默认是5222)
    _xmppStream.hostPort = account.hostPort;
    
    //4.发起连接
    NSError *error = nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    //5.打印
    if (error) {
        // 缺少必要的参数时,就会发起连接失败, 例如jid
        LCLog(@"%@", error);
    }else{
        LCLog(@"发起连接成功");
    }
}
#pragma mark -- 3.连接成功后, 发送登陆密码
-(void)sendLoginPwdToHost
{
    // 3. 发送密码
    
    // >1. 从单例中获取密码
    NSString *pwd = [LCAccount shareAccount].loginPwd;
    
    // >2. 发送
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    
    // >3. 打印
    if (error) {
        LCLog(@"%@", error);
    }else{
        LCLog(@"登陆密码发送成功");
    }
}
#pragma mark -- 3.连接成功后, 发送注册密码
-(void)sendRegitserPwdToHost
{
    // >1. 从单例中获取密码
    NSString *pwd = [LCAccount shareAccount].registerPwd;
    
    // >2. 发送注册密码
    NSError *error = nil;
    [_xmppStream registerWithPassword:pwd error:&error];
    
    if (error) {
        LCLog(@"%@", error);
    }else{
        LCLog(@"注册密码发送成功");
    }
}

#pragma mark -- 4. 发送在线消息给服务器
-(void)sendOnline
{
    // xmpp框架, 已经把所有的指令 封装成 对象了
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}
#pragma mark -- 注销

#pragma mark -- 1. 发送 离线消息 给服务器
-(void)sendOffline
{
    // xmpp框架, 已经把所有的指令 封装成 对象了
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}
#pragma mark -- 2. 与服务器断开连接
-(void)disconncetFromHost
{
    [_xmppStream disconnect];
}
#pragma mark -- 程序退出时释放相应的资源
-(void)teardownStream
{
    // 移除代理
    [_xmppStream removeDelegate:self];
    
    // 取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_message deactivate];
    
    // 断开连接
    [_xmppStream disconnect];
    
    // 清空资源
    _xmppStream = nil;
    _avatar = nil;
    _vCard = nil;
    _vCardStorage = nil;
    _roster = nil;
    _rosterStorage = nil;
    _message = nil;
    _messageStorage = nil;
}


//**********************************************************************
#pragma mark - XMPPStream 代理
#pragma mark -- 连接建立成功时,调用
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    // 3. 连接成功后, 发送密码
    LCLog(@"连接建立成功");
    
    // 判断是注册 还是 登陆
    if (self.isRegisterOperation) { // 注册
        
        // 发送注册密码
        [self sendRegitserPwdToHost];
        
    }else{ // 登陆
        
        // 发送登陆密码
        [self sendLoginPwdToHost];
    }
}
#pragma mark -- 登陆成功时,调用
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // 4. 发送 "在线" 消息 给服务器
    [self sendOnline];
    
    // 回调resultBlock
    if (_resultBlock) { // 如果block有值
        
        // 告诉block 登陆成功时, 是XMPPResultTypeLoginSuccess
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
}
#pragma mark -- 登陆失败时,调用
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    LCLog(@"登陆失败%@", error);
    
    // 回调resultBlock
    if (_resultBlock) { // 如果block有值
        
        // 告诉block 登陆失败时, 是XMPPResultTypeLoginFailure
        _resultBlock(XMPPResultTypeLoginFailure);
    }
}
#pragma mark -- 注册成功时,调用
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    LCLog(@"注册成功");
    // 回调resultBlock
    if (_resultBlock) { // 如果block有值
        
        // 告诉block 注册成功时, 是XMPPResultTypeRegisterSuccess
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}
#pragma mark -- 注册失败时,调用
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    LCLog(@"注册失败%@", error);
    
    // 回调resultBlock
    if (_resultBlock) { // 如果block有值
        
        // 告诉block 注册失败时, 是XMPPResultTypeRegisterFailure
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
}

#pragma mark - 程序退出时, 调用
-(void)dealloc
{
    // 释放资源
    [self teardownStream];
}
@end
