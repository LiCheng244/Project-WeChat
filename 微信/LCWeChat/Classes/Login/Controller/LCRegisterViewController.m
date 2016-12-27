//
//  LCRegisterViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCRegisterViewController.h"

@interface LCRegisterViewController ()
/**
 *  用户名
 */
@property (strong, nonatomic) IBOutlet UITextField *userNameTF;
/**
 *  密码
 */
@property (strong, nonatomic) IBOutlet UITextField *pwdTF;

@end

@implementation LCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];



}
#pragma mark - 注册按钮
- (IBAction)register:(id)sender {
    
    //注册
    // 1. 保存注册的用户名和密码,先放到account单例中
    [LCAccount shareAccount].registerUserName = self.userNameTF.text;
    [LCAccount shareAccount].registerPwd = self.pwdTF.text;
    
    // 设置标识为注册操作
    [XMPPTool sharedXMPPTool].registerOperation = YES;

    // 2. 调用工具类的注册方法
    __weak typeof(self) weakSelf = self;
    [[XMPPTool sharedXMPPTool] xmppRegister:^(XMPPResultType resultType) {

        // 处理服务器返回的结果
        [weakSelf handlXMPPResultType:resultType];
        
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
        if (resultType == XMPPResultTypeRegisterSuccess) {
            NSLog(@"注册成功");
            
            [MBProgressHUD showSuccess:@"注册成功,回到登陆界面登陆"];
            
        }else if(resultType == XMPPResultTypeRegisterFailure){
            NSLog(@"注册失败");
            
            [MBProgressHUD showError:@"注册失败, 用户名重复"];
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


#pragma mark - 取消按钮
- (IBAction)cancelClick:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
