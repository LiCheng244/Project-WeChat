//
//  LCChatViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/25.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCChatViewController.h"

@interface LCChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    /**
     *   数据库返回结果控制器
     */
    NSFetchedResultsController *_resultContr;
}
/**
 *  表格
 */
@property (strong, nonatomic) IBOutlet UITableView *tableView;
/**
 *  输入框距离底部的约束
 */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottonConstraint;


@end

@implementation LCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 键盘将要显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 键盘将要消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    // 加载数据库的聊天数据
    [self loadDataFromDataBase];
    

}
#pragma mark - 从数据库加载聊天消息
-(void)loadDataFromDataBase
{
    // 1. 上下文
    NSManagedObjectContext *context = [XMPPTool sharedXMPPTool].messageStorage.mainThreadManagedObjectContext;
    
    // 2. 查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 3. 查询条件
    // >1.(只获取当前登录用户的消息, 并且 只获取和当前聊天好友的消息)
    NSString *loginJidStr = [XMPPTool sharedXMPPTool].xmppStream.myJID.bare; // 当前用户名
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", loginJidStr, self.friendJid.bare];
    request.predicate = pre;
    
    // >2. 设置时间排序(升序)
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 4. 执行
    // 1> 请求结果控制器
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    // 2> 代理
    _resultContr.delegate = self;
    // 3> 执行
    NSError *error = nil;
    [_resultContr performFetch:&error];
}

#pragma mark - UITableViewDataSource 代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultContr.fetchedObjects.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"chatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:ID];
    }
    
    /**
     *  获取 并 显示 聊天信息
     */
    
    // 获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultContr.fetchedObjects[indexPath.row];
    
    // 1> 获取原始的xml数据
    XMPPMessage *message = msgObj.message;
    
    // 2> 获取文件的类型
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    // 判断文件类型
    if ([bodyType isEqualToString:@"image"]) { // 图片
        
        // 获取子节点data数据
        NSData * imageData = [self getAttachmentDataWithMessage:message];

        // 赋值
        cell.imageView.image = [UIImage imageWithData:imageData];
        
    }else if([bodyType isEqualToString:@"sound"]){ // 音频
        
    }else{ // 纯文本
        
        cell.textLabel.text = message.body;
    }
 
    return cell;
    
}

#pragma mark - 文件发送按钮 ,以图片发送为例
- (IBAction)chooseImageClick:(id)sender {
    
    // 从 手机图片库 选取
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // 样式
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    // 跳转
    [self presentViewController:picker animated:YES completion:nil];
}



#pragma mark - UITextFieldDelegate 代理
#pragma mark -- 发送聊天数据
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    // 向服务器发送聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:textField.text];
    
    [[XMPPTool sharedXMPPTool].xmppStream sendElement:msg];
    
    // 清空输入框文本
    textField.text = nil;
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate 代理
#pragma mark -- 用户选择的图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 获取图片
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    
    // 发送图片
    [self sendAttachmentWithData:UIImagePNGRepresentation(img) bobyType:@"image"];
    
    // 隐藏控制器
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 发送文件方法
-(void)sendAttachmentWithData:(NSData *)data bobyType:(NSString *)bodyType
{
    // 编辑要发送的数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    // 设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    [msg addBody:bodyType];
    
    // 把文件转换成字符串(使用base64编码转换)
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    
    // 创建节点(定义附件)
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    // 添加子节点
    [msg addChild:attachment];
    
    // 发送消息
    [[XMPPTool sharedXMPPTool].xmppStream sendElement:msg];
    
}

#pragma mark - 获取子节点的数据
-(NSData *)getAttachmentDataWithMessage:(XMPPMessage *)message
{
    // 获取所有的子节点
    NSArray *child = message.children;
    
    // 返回的数据
    NSData *data = nil;
    
    // 遍历所有子节点
    for (XMPPElement *note in child) {
        
        // 获取节点的名字,进行判断
        if ([[note name] isEqual:@"attachment"]) { // 此时说明有文件
            
            // 1. 获取文件字符串
            NSString *dataStr = [note stringValue];
            // 2. 字符串 --> data
            data = [[NSData alloc] initWithBase64EncodedString:dataStr options:0];
        }
    }
    return data;
}


#pragma mark - NSFetchedResultsControllerDelegate 代理
#pragma mark -- 当数据库内容改变时, 调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 刷新表格
    [self.tableView reloadData];
    
    // 表格滚动到底部
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultContr.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    
}


#pragma mark - 键盘通知事件触发方法
#pragma mark -- 键盘将要显示
-(void)kbWillShow:(NSNotification *)noti
{
    // 显示时 改变约束 buttonConstraint
    
    // 获取键盘高度
    CGFloat kbHeight = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // 修改约束
    self.bottonConstraint.constant = kbHeight;
}
#pragma mark -- 键盘将要隐藏
-(void)kbWillHide:(NSNotification *)noti
{
    // 修改约束
    self.bottonConstraint.constant = 0;
}

#pragma mark - UIScrollViewDelegate 代理
#pragma mark -- 表格滚动, 隐藏键盘
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
