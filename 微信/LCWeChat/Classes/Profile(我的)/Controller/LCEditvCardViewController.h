//
//  LCEditvCardViewController.h
//  LCWeChat
//
//  Created by LiCheng on 16/1/21.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LCEditvCardViewController;

@protocol LCEditvCardViewControllerDelegate <NSObject>
/**
 *  完成保存
 *
 *  @param editVC 编辑电子名片的控制器
 *  @param sender 点击保存的按钮
 */
-(void)editvCardViewController:(LCEditvCardViewController *)editVC didFinishSave:(id)sender;
@end

@interface LCEditvCardViewController : UITableViewController


/**
 *  上一个控制器传过来的cell(控制器: 个人信息控制器)
 */
@property (nonatomic, strong) UITableViewCell *cell;

/**
 *  代理
 */
@property (nonatomic, weak) id<LCEditvCardViewControllerDelegate> delegate;
@end
