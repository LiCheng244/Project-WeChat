//
//  LCContactsViewController.m
//  LCWeChat
//
//  Created by LiCheng on 16/1/22.
//  Copyright © 2016年 LiCheng. All rights reserved.
//

#import "LCContactsViewController.h"
#import "LCChatViewController.h"

@interface LCContactsViewController ()<NSFetchedResultsControllerDelegate>{
    
    NSFetchedResultsController *_resultContr; // 查找好友的 返回结果 对象
}

@end

@implementation LCContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 获取好友信息(在沙盒的XMPPRoster.sql里)
   [self getContactsInfoFormCoreData2];
}

#pragma mark - 获取联系人信息,方法2
-(void)getContactsInfoFormCoreData2
{
    // 1. 关联上下文
    NSManagedObjectContext *rosterContext = [XMPPTool sharedXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    // 2. request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 3. 设置查询条件
    // (升序排序)
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // (过滤) 对方没有同意添加为好友的, 不显示出来
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@", @"none"];
    request.predicate = pre;
    
    // 4. 执行请求
    //  -- 创建结果控制器
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    //  -- 设置代理
    _resultContr.delegate = self;
    //  -- 执行
    NSError *error = nil;
    [_resultContr performFetch:&error];
    
}
#pragma mark - 获取联系人信息,方法1
-(NSArray *)getContactsInfoFormCoreData1
{
    // 1. 关联上下文
    NSManagedObjectContext *rosterContext = [XMPPTool sharedXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    // 2. request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 3. 设置查询条件 (升序排序)
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 3. 执行请求
    NSError *error = nil;
    // 接收结果
    NSArray *users = [rosterContext executeFetchRequest:request error:&error];
    
    return users;
}

#pragma mark - 显示好友信息
-(void)showContactInfo:(XMPPUserCoreDataStorageObject *)user toCell:(UITableViewCell *)userCell
{
    // 1. 好友的名称
    userCell.textLabel.text = user.displayName;
    
    // 2. 判断用户是否在线
    /**
     *  0: 代表在线
     1: 代表离开
     2: 代表离线
     */
    switch ([user.sectionNum integerValue]) {
        case 0:
            userCell.detailTextLabel.text = @"在线";
            break;
            
        case 1:
            userCell.detailTextLabel.text = @"离开";
            break;
            
        case 2:
            userCell.detailTextLabel.text = @"离线";
            break;
            
        default:
            userCell.detailTextLabel.text = @"未知";
            break;
    }
    
    
    // 3. 显示好友头像
    // 默认的情况:不是程序一启动就有头像, 第一次的话需要自己从服务器上去获取
    if (user.photo) { // 有头像
        userCell.imageView.image = user.photo;
        
    }else{ // 没有头像
        
        //1. 从服务器获取头像
        NSData *imgData = [[XMPPTool sharedXMPPTool].avatar photoDataForJID:user.jid];
        
        // 2. 设置头像
        userCell.imageView.image = [UIImage imageWithData:imgData];
    }
    
    
    // 4. 监听用户登录状态的改变
    // 方式1: kvo
    //[user addObserver:self forKeyPath:@"sectionNum" options:(NSKeyValueObservingOptionNew) context:nil];
    // 方式2: 使用第二个获取数据的方法
    
}

#pragma mark - UITableViewDataSource 代理
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultContr.fetchedObjects.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
    
    // 显示好友信息
    [self showContactInfo:user toCell:cell];
    
    return cell;
}
#pragma mark -- 实现此方法, 显示左划出现的删除按钮
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 判断显示的按钮样式
    if (editingStyle == UITableViewCellEditingStyleDelete) { // delete按钮
        
        // 获取好友
        XMPPUserCoreDataStorageObject *user = _resultContr.fetchedObjects[indexPath.row];
        NSLog(@"%@", user);
        // 删除好友(使用花名册模块)
        [[XMPPTool sharedXMPPTool].roster removeUser:user.jid];
    }
}

#pragma mark - UITableViewDelegate 代理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 获取jid
    XMPPJID *friendJid = [_resultContr.fetchedObjects[indexPath.row] jid];
    
    // 手动 进入聊天界面(传 jid)
    [self performSegueWithIdentifier:@"toChatVCSegue" sender:friendJid];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 获取目标控制器
    id destVC = segue.destinationViewController;

    if ([destVC isKindOfClass:[LCChatViewController class]]) {
        
        LCChatViewController * chatVC = destVC;
        // 赋值
        chatVC.friendJid = sender;
    }
}

#pragma mark - NSFetchedResultsControllerDelegate 代理
#pragma mark -- 当数据库内容改变时 ,触发
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 该方法在主线程中调用
    
    // 刷新表格
    [self.tableView reloadData];
}

#pragma mark - kvo 当被监听对象改变时调用
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // 刷新表格
    [self.tableView reloadData];
}
@end
