


/**
 *  ? 怎么 把 appdelegate 的登陆结果告诉给WCLoginViewController?
 
    答: 代理, block, 通知
 */

/**
 *  block 循环引用
    
    在自己写的block中调用self会造成循环引用(强引用)
    - 使用__weak 弱引用 解决,
    - 或者在block回调后,清空block

 */

/**
 *   // > 2. 调用appdelegate.h的xmpplogin方法
 AppDelegate *appdelegate = [UIApplication sharedApplication].delegate; // 获取appDelegate
 */

/**
 *   电子名片(vCard)
 
    1> 是一种机制: 获取电子名片 或者 发送电子名片数据.
    2> 获取电子名片, 使用XMPPFramework 里面提供的 "电子名片模块 "
    3> 如何使用:  
        > 导入 "电子名片模块" 头文件
        > 激活 "电子名片模块"
    4> "电子名片模块 "的内部实现:
        > 发送请求,从服务器获取电子名片(个人信息)数据
            <iq type="get" to="lisi@licheng.local"><vCard xmlns="vcard-temp"/></iq>
        > 接收服务器返回的数据, 把数据缓存到本地的数据库
            为什么mycVard.jid是空的?
            因为: 服务器返回的电子名片的xml数据中没有JABBERID节点
 */

/**
 *   打开xmpp的日志
 
    1> 打开XMPP/Core/XMPPLogging.h文件, 第67行, XMPP_LOGGING_ENABLED 设置为1
    2> 需要配置xmpp日志的启动. 在appdelegate.m的didfinishlauching方法中添加:
        前提: 导入:DDLog.h 和 DDTTYLogger.h
        [DDLog addLogger:[DDTTYLogger sharedInstance]];

 */


/**
 *   对openfire的二次开发
 
    1> openfire基于java开发, 获取到源代码,进行二次开发
    2> 每开发一个功能模块, 最终打包成一个插件
    3> 将插件添加到openfire后台, app就可以实现该插件里面的功能.
 
 */

/**
 *    花名册模块的数据存储原理
    
    1> 沙盒里保存的数据库里的数据只是单个用户的
    2> 如果其他用户登录, 则数据库里原来用户的数据会被删除
 */

/**
 *    XMPP框架 实时聊天实现
 
    xmpp 提供了 "消息模块" , 来实现实时聊天.
    不管是哪个用户登录, 实时聊天的数据都保存在同一个数据库的表中. 
 
    实现:
    1> 接收到好友的聊天数据后, 把数据保存到数据库. 
    2> 从数据库中获取, 显示到表格上

 */

/**
 *  文件发送
    
    图片, 音频, 视频, 文档等.
    xmpp对ios不支持音频等发送, 需要自己实现.
 
    实现方式:
 
        1> 方式二: 添加属性 bodyType 确定发送的文件类型
                  添加子节点 attachment
 
         <message type="chat" from="" to="lisi@licheng.local" bodyType="image/text/sound/doc/xls">
         <body>存文本消息</body>
         <attachment>文件内容 转成 字符串 </attachment>  // 自己添加这一行
         </message>
 
        这种方式一定要有body子节点, 不然没法发送
 
        2> 方式二: 通过 文件服务器 来实现
 
        -- 1. ios客户端A 把文件上传到 文件服务器
        -- 2. 文件服务器 返回文件路径给 ios客户端A
        -- 3. ios客户端A 把文件路径 传递给 openfire服务器
        -- 4. openfire服务器 把文件路径 发送给 ios客户端B
        -- 5. ios客户端B 通过文件路径 到 文件服务器 读取文件
 
 
 */

