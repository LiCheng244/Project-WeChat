//
//  LCAddContactViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/25.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCAddContactViewController.h"

@interface LCAddContactViewController ()

/**
 *  输入框
 */
@property (strong, nonatomic) IBOutlet UITextField *textTF;

@end

@implementation LCAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)addContactClick:(id)sender {
    
    // 添加好友的情况
    
    // 前提:
    // 获取用户输入的好友名称
    NSString *userName = self.textTF.text;
    
    
    // 1. 不能添加自己为好友
    if ([userName isEqualToString:[LCAccount shareAccount].loginUserName]) {
        
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    // 2. 已经存在的好友不能再添加
    
    //  -- 用户名jid
    XMPPJID *userJid = [XMPPJID jidWithUser:userName domain:[LCAccount shareAccount].domain resource:nil];
    //  -- 从数据库中获取 输入的好友是否存在
    BOOL userExists = [[XMPPTool sharedXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[XMPPTool sharedXMPPTool].xmppStream];
    
    //  -- 判断
    if (userExists == YES) { // 已添加
        [self showMsg:@"好友已经存在"];
        return;
    }
    
    // 3. 添加好友
    [[XMPPTool sharedXMPPTool].roster subscribePresenceToUser:userJid];
    
    
    /**
     *   xmpp 添加好友 现有openfire中存在的问题
        
     
        1> 添加不存在的好友时, 数据库、通讯录里面也显示.
     
            解决1:
            > 服务器可以拦截添加好友的请求, 如果服务器当前数据库没有好友, 不要返回信息
     
            解决2:
            > 过滤数据库的查询请求, 字段: subscription  
                字段类型: none , 对方没有同意添加好友
                         to , 发给对方添加好友请求的
                         form , 别人加你的请求
                         both , 双方互为好友
            > 在 LCContactsViewController 控制器中, 获取联系人信息时, 添加过滤条件
     
     */

}

#pragma mark - 提示信息
-(void)showMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    
}
@end
