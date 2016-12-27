//
//  LCLoginViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/17.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCLoginViewController.h"
#import "AppDelegate.h"

@interface LCLoginViewController ()
/**
 *  用户名
 */
@property (strong, nonatomic) IBOutlet UITextField *userTF;
/**
 *  密码
 */
@property (strong, nonatomic) IBOutlet UITextField *pwdTF;


@end

@implementation LCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - 登陆按钮
- (IBAction)loginClick:(id)sender {
    
    // 1. 判断有没有输入用户名和密码
    if (self.userTF.text.length == 0 || self.pwdTF.text.length == 0) {
        NSLog(@"请输入用户名和密码");
        
        return;
    }
    
    // 提示用户正在登陆
    [MBProgressHUD showMessage:@"正在登陆中"];
    
    
    // 2. 登陆到服务器
    
    // > 1. 将用户名和密码先放在account单例里面
    [LCAccount shareAccount].loginUserName = self.userTF.text;
    [LCAccount shareAccount].loginPwd = self.pwdTF.text;
    
    // > 2. 登陆
    // 设置标识, 为登陆
    [XMPPTool sharedXMPPTool].registerOperation = NO;
    
    // 在block中调用self会造成循环引用(强引用), 使用__weak 弱引用解决,或者在block回调后,清空block
    __weak typeof(self) selfWeak = self;
    [[XMPPTool sharedXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        
        // 处理服务器返回的结果
        [selfWeak handlXMPPResultType:resultType];
    }];
}

#pragma mark - 处理登陆服务器返回的结果
-(void)handlXMPPResultType:(XMPPResultType)resultType
{
    //  **** 回到主线程 操作UI
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 移除提示
        [MBProgressHUD hideHUD];
        
        // 判断结果类型
        if (resultType == XMPPResultTypeLoginSuccess) {
            NSLog(@"登陆成功");
            
            // 1. 登陆成功 切换到主界面
            [self changeToMain];
            
            // 2. 设置登陆状态
            [LCAccount shareAccount].login = YES;
            
            // 3. 保存用户信息到沙盒
            [[LCAccount shareAccount] saveToSandBox];
           
        }else if(resultType == XMPPResultTypeLoginFailure){
            NSLog(@"登陆失败");
            [MBProgressHUD showError:@"登陆失败, 用户名或者密码错误"];
        }
    });
}
#pragma mark - 切换到主界面
-(void)changeToMain
{
    // 1. 获取mian.storyboard 的第一个控制器
    id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    
    // 2. 切换window的根控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

-(void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
