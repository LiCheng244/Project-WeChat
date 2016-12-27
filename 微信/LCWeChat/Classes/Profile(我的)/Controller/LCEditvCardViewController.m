//
//  LCEditvCardViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/21.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCEditvCardViewController.h"

@interface LCEditvCardViewController ()
/**
 *  输入框
 */
@property (strong, nonatomic) IBOutlet UITextField *textTF;

@end

@implementation LCEditvCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = self.cell.textLabel.text;
    
    // 设置默认值
    self.textTF.text = self.cell.detailTextLabel.text;
}


#pragma mark - 保存按钮
- (IBAction)savevCardBtnClick:(id)sender {
    
    // 1. 把cell的label的值更改
    self.cell.detailTextLabel.text = self.textTF.text;
    
    // 重新布局, 使之前没有数据的label重新布局
    [self.cell layoutSubviews];
    
    // 2. 隐藏控制器
    [self.navigationController popViewControllerAnimated:YES];
    
    // 3. 通知上一个控制器
    if ([self.delegate respondsToSelector:@selector(editvCardViewController:didFinishSave:)]) {
        [self.delegate editvCardViewController:self didFinishSave:sender];
    }
    
}
@end
