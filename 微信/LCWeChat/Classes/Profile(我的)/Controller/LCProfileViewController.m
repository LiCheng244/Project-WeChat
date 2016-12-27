//
//  LCProfileViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/21.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCProfileViewController.h"
#import "XMPPvCardTemp.h"
#import "LCEditvCardViewController.h"

@interface LCProfileViewController ()<LCEditvCardViewControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/**
 *  头像
 */
@property (strong, nonatomic) IBOutlet UIImageView *iconImageV;
/**
 *  昵称
 */
@property (strong, nonatomic) IBOutlet UILabel *nickNameL;
/**
 *  微信号
 */
@property (strong, nonatomic) IBOutlet UILabel *wcNumL;
/**
 *  公司
 */
@property (strong, nonatomic) IBOutlet UILabel *orgNameL;
/**
 *  部门
 */
@property (strong, nonatomic) IBOutlet UILabel *orgUnitsL;
/**
 *  职位
 */
@property (strong, nonatomic) IBOutlet UILabel *titleL;
/**
 *  电话
 */
@property (strong, nonatomic) IBOutlet UILabel *telL;
/**
 *  邮箱
 */
@property (strong, nonatomic) IBOutlet UILabel *emialL;


@end

@implementation LCProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.获取登陆用户的电子名片信息
    XMPPvCardTemp *myvCard = [XMPPTool sharedXMPPTool].vCard.myvCardTemp;
    
    
    // 2.设置属性
    
    // 头像
    if (myvCard.photo == nil) { // 没有头像
        self.iconImageV.image = [UIImage imageNamed:@"login_defaultAvatar"];
        
    }else{ // 有头像
        self.iconImageV.image = [UIImage imageWithData:myvCard.photo];
    }
    
    // 昵称
    self.nickNameL.text = myvCard.nickname;
    
    // 微信号
    self.wcNumL.text = [LCAccount shareAccount].loginUserName;
    
    
    // 公司
    self.orgNameL.text = myvCard.orgName;
    
    // 部门
    if (myvCard.orgUnits.count > 0) {
        self.orgUnitsL.text = myvCard.orgUnits[0];
    }
    
    // 职位
    self.titleL.text = myvCard.title;
    
    // 电话
    if (myvCard.telecomsAddresses.count > 0) {
        self.telL.text = myvCard.telecomsAddresses[0]; // xmpp没有解析
    }
    self.telL.text = myvCard.note;
    
    // 邮箱
    self.emialL.text = myvCard.emailAddresses[0];
    
}

#pragma mark - UITableViewDelegate 代理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 根据不同的cell的tag 进行相应的操作
    /**
     *  tag = 0 换头像
        tag = 1 进入下一个控制器
        tag = 2 不操作
     */
    
    // 1. 获取选中的cell
    UITableViewCell *selCell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 2. 判断
    switch (selCell.tag) {
        case 100:
            LCLog(@"换头像");
            [self choseImage];
            break;
            
        case 101:
            LCLog(@"进入下一个界面");
            // 根据 连线的标识 跳转
            [self performSegueWithIdentifier:@"toEditVCSegue" sender:selCell];
            // 传cell
            break;
            
        case 102:
            LCLog(@"不操作");
            break;
            
        default:
            break;
    }
}
#pragma mark - 当前的视图控制器即将被另一个视图控制器所替代时, 触发
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /**
     *      该方法主要解决两个问题
     
        1> 获取所要跳转到的视图控制器（ViewController）；
        2> 同时，将上一个视图的数据，传递给下一个视图。
     */
    
    
    // 获取目标控制器
    id destVC = segue.destinationViewController;
    
    // 判断 目标控制器的类型
    if ([destVC isKindOfClass:[LCEditvCardViewController class]]) {
        
        // 设置编辑电子名片控制器的cell
        LCEditvCardViewController *editVC = destVC;
        
        // 赋值
        editVC.cell = sender;
        
        // 设置代理
        editVC.delegate = self;
    }
    
}

#pragma mark - 选择图片
-(void)choseImage
{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"从相册中选择", nil];
    
    // 显示在哪个view上
    [sheet showInView:self.view];
}

#pragma mark - UIImagePickerControllerDelegate 代理
#pragma mark -- 完成选择 触发
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 获取修改后的图片
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    
    // 更改cell的头像图片
    self.iconImageV.image = editImage;
    
    // 移除图片选择控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 把新的头像保存到服务器
    [self editvCardViewController:nil didFinishSave:nil];
    
}
#pragma mark - UIActionSheetDelegate 代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // buttonIndex 按钮的标识
    
    
    if (buttonIndex == 2) return;

    // 图片选择器
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self; // 设置代理
    picker.allowsEditing = YES; // 允许编辑图片(可以放大缩小)
    
    // 判断点击的按钮
    if (buttonIndex == 0) { // 照相
        
        // 照相模式
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else{ // 相册
        
        // 照相模式
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    }
    
    // 显示控制器
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 编辑电子名片控制器的代理
-(void)editvCardViewController:(LCEditvCardViewController *)editVC didFinishSave:(id)sender
{
    LCLog(@"完成保存");
    
    // 把数据保存到服务器
    
    // 1. 获取当前电子名片
    XMPPvCardTemp *myVCard = [XMPPTool sharedXMPPTool].vCard.myvCardTemp;
    
    // 2. 重新设置myVCrad的属性
    myVCard.photo = UIImageJPEGRepresentation(self.iconImageV.image, 1.00); // 按1.00比例上传图片
    myVCard.nickname = self.nickNameL.text;
    myVCard.orgName = self.orgNameL.text;
    if (self.orgUnitsL.text != nil) {
        myVCard.orgUnits = @[self.orgUnitsL.text];
    }
    myVCard.title = self.titleL.text;
    myVCard.note = self.telL.text;

    myVCard.mailer = self.emialL.text;
    
    // 3. 把数据保存到服务器
    [[XMPPTool sharedXMPPTool].vCard updateMyvCardTemp:myVCard];
    /**
     *  内部实现:
        
        数据上传是把整个电子名片的数据都重新上传了一次, 包括图片
     */
}

@end
