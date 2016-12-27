//
//  LCMeViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/18.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCMeViewController.h"
#import "AppDelegate.h"
#import "LCLoginViewController.h"
#import "XMPPvCardTemp.h"

@interface LCMeViewController ()

/**
 *  头像
 */
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
/**
 *  微信号
 */
@property (strong, nonatomic) IBOutlet UILabel *wcNumL;

@end

@implementation LCMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  电子名片
     
        显示头像和微信号
        从数据库中获取用户信息
     */
    
    // 1.获取登陆用户的电子名片信息
    // 内部实现: 会去数据库查找, 不需要我们自己写
    XMPPvCardTemp *myvCard = [XMPPTool sharedXMPPTool].vCard.myvCardTemp;
    
    // 2.获取头像, 设置头像
    if (myvCard.photo == nil) { // 没有头像
        self.iconImage.image = [UIImage imageNamed:@"login_defaultAvatar"];
        
    }else{ // 有头像
        self.iconImage.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 3.微信号(显示用户名)
    self.wcNumL.text = [NSString stringWithFormat:@"微信号:%@",[LCAccount shareAccount].loginUserName];
}

#pragma mark - 注销按钮
- (IBAction)logoutClick:(id)sender {
    
    // 注销
    [[XMPPTool sharedXMPPTool] xmppLogout];
    
    // 把沙盒里的登陆状态修改为NO
    [LCAccount shareAccount].login = NO;
    [[LCAccount shareAccount] saveToSandBox];
    
    // 切换到登陆控制器
    [self changeToLogin];
    
    
}
#pragma mark - 切换到登陆控制器
-(void)changeToLogin
{
    // 1. 获取mian.storyboard 的第一个控制器
    id vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
    
    // 2. 切换window的根控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
}

@end
