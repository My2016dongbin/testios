//
//  VSGMacro.h
//  VSGVPNSDK
//
//  Created by Gavin on 16/1/18.
//  Copyright © 2016年 com.leadsec. All rights reserved.
//

#ifndef VSGMacro_h
#define VSGMacro_h

/**
 *  认证类型枚举值
 */
typedef NS_ENUM(NSUInteger, VSGAuthType) {
    VSGAuthTypePassword = 1,
    VSGAuthTypeCert = 2,
    VSGAuthTypeSendSMS = 3,
    VSGAuthTypeAuthSMS = 4,
    VSGAuthTypeToken = 5,
    VSGAuthTypeChangePwd = 6,
    //VSGAuthTypeSendVertifyCode = 7,
    VSGAuthTypeAuthVertifyCode = 8,
    VSGAuthTypeAuthUUID = 9,
    VSGAuthTypeCollectUUID = 10,
    VSGAuthTypeFIDORegister = 11,
    VSGAuthTypeFIDOAuth = 12,
    VSGAuthTypeFIDOCheck = 13,
    VSGAuthTypeFIDOUnRegister = 14,
};

/**
 *  保护资源的类型
 */
typedef NS_ENUM(NSUInteger, VSGResourceType) {
    VSGResourceTypeRemoteApp = 1,
    VSGResourceTypeCSResource = 2,
    VSGResourceTypeNCResource = 3,
};

/**
 *  回调事件类型
 */
typedef NS_ENUM(NSUInteger, VSGServiceCallBackType) {
    VSGServiceCallBackTypeInitTunnelFail = 1,
    VSGServiceCallBackTypeDownloadCertFileFinished = 10,
};

/**
 *  当前VPN的状态,目前只用到 "默认" "断开" 和 "连接" 三种情况.
 */
typedef NS_ENUM(NSUInteger, VSGVPNStatus) {
    VSGVPNStatusInvalid = 0,  //默认
    VSGVPNStatusDisconnected = 1,  //断开
    VSGVPNStatusConnecting = 2,
    VSGVPNStatusConnected = 3,    //连接
    VSGVPNStatusReasserting = 4,
    VSGVPNStatusDisconnecting = 5,
    VSGVPNStatusReConnecting = 6, //网络切换，正在重新连接
    VSGVPNStatusWaitingNet = 7, //网络切换，无网络连接，等待
    VSGVPNStatusAuthing = 9,  //认证中
};

/**
 *  认证参数的key值
 */
#define VSGAuthPassWordkUserName      @"VSGAuthPassWordkUserName"
#define VSGAuthPassWordkPassword      @"VSGAuthPassWordkPassword"
#define VSGAuthVPNAddress             @"VSGAuthVPNAddress"
#define VSGAuthVPNPort                @"VSGAuthVPNPort"

#define VSGAuthCertName               @"VSGAuthCertName"
#define VSGAuthCertPassword           @"VSGAuthCertPassword"

//国密证书传值
#define VSGAuthSIGNCertName           @"VSGAuthSIGNCertName"
#define VSGAuthSIGNCertPassword       @"VSGAuthSIGNCertPassword"
#define VSGAuthENCCertName            @"VSGAuthENCCertName"
#define VSGAuthENCCertPassword        @"VSGAuthENCCertPassword"

#define VSGAuthRequestSMSCode         @"VSGAuthRequestSMSCode"
#define VSGAuthSMSCode                @"VSGAuthSMSCode"
#define VSGAuthTokenCode              @"VSGAuthTokenCode"
#define VSGAuthVerifyCode             @"VSGAuthVerifyCode"
#define VSGAuthChangePwdOld           @"VSGAuthChangePwdOld"
#define VSGAuthChangePwdNew           @"VSGAuthChangePwdNew"

#define VSGAuthUUIDValue              @"VSGAuthUUIDValue"
#define VSGAuthCollectUUID            @"VSGAuthCollectUUID"

//本地记录是否已注册FIDO
#define VSGAuthFIDORegister           @"VSGAuthFIDORegister"
#define VSGAuthFIDOUserName           @"VSGAuthFIDOUserName"
//查询请求
#define VSGAuthFIDOCheckRequest       @"VSGAuthFIDOCheckRequest"
#define VSGAuthFIDOUnRegister         @"VSGAuthFIDOUnRegister"

/**
 *  认证结果枚举
 */
typedef NS_ENUM(NSUInteger, VSGAuthResult) {
    
    VSGAUTH_SUCCESS                             =           0x00000000, //操作成功
    VSGAUTH_MULTIFACTOR_NEED_USERNAMEPASSWORD   =           0x00000001, //多因素认证,上一因素认证成功,口令未验证
    VSGAUTH_MULTIFACTOR_NEED_CERTIFICATE        =           0x00000002, //多因素认证,上一因素认证成功,证书未验证
    VSGAUTH_MULTIFACTOR_NEED_TOKEN              =           0x00000004, //多因素认证,上一因素认证成功,动态令牌未验证
    VSGAUTH_MULTIFACTOR_TOKEN_ERROR             =           0x80000007, //多因素认证,上一因素认证成功,动态令牌错
    VSGAUTH_MULTIFACTOR_NEED_SMS                =           0x00000008, //多因素认证,上一因素认证成功,短信未认证
    VSGAUTH_MULTIFACTOR_NEED_HARDWARE           =           0x00000010, //多因素认证,上一因素认证成功,硬件特征码未认证
    VSGAUTH_MULTIFACTOR_NEED_BIND_IP            =           0x00000020, //多因素认证,上一因素认证成功,绑定主机未认证
    VSGAUTH_MULTIFACTOR_NEED_MAC                =           0x00000040, //多因素认证,上一因素认证成功,绑定 MAC 未认证
    VSGAUTH_FRIST_LOGIN_MODIFY_PSW              =           0x00000080, //口令因素,首次登陆,需修改密码
    VSGAUTH_FRIST_LOGIN_PSW_TIMEOUT             =           0x00000100, //口令因素,首次登陆,需修改密码
    
    VSGAUTH_USER_NOT_FOUND_ERROR                =           0x80000001, //认证失败,无该用户
    VSGAUTH_USER_PASSWORD_ERROR                 =           0x80000002, //认证失败,口令错
    VSGAUTH_CERTIFICATE_ERROR                   =           0x80000003, //认证失败,证书错
    VSGAUTH_SMS_ERROR                           =           0x80000008, //认证失败,短信码认证错误
    VSGAUTH_REQUEST_SMS_ERROR                   =           0x80000053, //短信验证码发送失败
    VSGAUTH_MULTIFACTOR_REQUEST_NOT_LEGAL       =           0x80000016, //多因素请求不合法
    VSGAUTH_USERNAME_LOCKED                     =           0x80000017, //用户名已锁定
    VSGAUTH_USER_OUTOF_VALID_PERIOD             =           0x80000019, //当前用户不在登录有效期内
    VSGAUTH_USER_OUTOF_VALID_RESOURCES          =           0x80000020, //该用户没用任何访问权限
    VSGAUTH_FORCE_ATTACK_LOCK                   =           0x80000022, //暴力破解锁定用户或IP
    VSGAUTH_ONLINE_OVER_LICENSE                 =           0x80000021, //系统在线用户数已达最大
    VSGAUTH_USER_NO_ACL                         =           0x8000001e, //该用户没有任何访问权限
    VSGAUTH_USER_OR_PWD_WRONG                   =           0x8000001A, //用户名或密码错误
    
    VSGAUTH_GET_RESOURCE_ERROR                  =           0xffffffff, //获取资源错误
    
    VSGAUTH_USER_NO_NET                         =           0x80000030, //无联网
    VSGAUTH_USER_TIME_OUT                       =           0x80000031, //请求超时，出错
    VSGAUTH_USER_NO_VALID_WORLD                 =           0x80000032, //用户名或密码为空
    VSGAUTH_USER_NO_VALID_ADDRESS               =           0x80000033, //无效网络地址
    VSGAUTH_CERT_AUTH_FAIL                      =           0x80000034, // 证书认证失败
    VSGAUTH_CERT_WRONG_PWD                      =           0x80000035, // 证书密码错误
    VSGAUTH_CERT_NO_CERT                        =           0x80000036, // 无效的证书
    
    VSGAUTH_MULTAPP_NO_AUTH                     =           0x80000040, // 多APP，还没认证过
    VSGAUTH_MULTAPP_NO_SESSION                  =           0x80000014, // 多APP，认证超时
    
    VSGAUTH_CHANGE_PWD_OLD_ERROR                =           0x80000043, // 旧口令错误
    VSGAUTH_CHANGE_PWD_LEN_ERROR                =           0x80000044, // 口令长度不符合要求
    VSGAUTH_CHANGE_PWD_CONTAIN_NAME             =           0x80000045, // 口令中不能包含用户名
    VSGAUTH_CHANGE_PWD_ERROR_SAME               =           0x80000046, // 新旧口令不能相同
    VSGAUTH_CHANGE_PWD_CONTAIN_CHARA_ERROR      =           0x80000047, // 口令字符组成不符合要求
    
    VSGAUTH_USER_NEED_VERTIFYCODE               =           0x80000050, // 需要开启验证码
    VSGAUTH_USER_WRONG_CERT                     =           0x80000051, // 用户证书不匹配
    
    VSGAUTH_USER_INNER_ERROR                    =           0x80000500, // 内部错误
    
    VSGAUTH_USER_COLLECT_UUID                   =           0x80000058, // 需要收集终端信息
    
    VSGAUTH_USER_COLLECT_REPEAT                 =           0x80000065, // 终端信息已提交...
    VSGAUTH_USER_FIDO_REQUIRE                   =           0x80000066, // 提示应该注册FIDO
    
    
    //以下是Fido返回的
    VSG_FIDO_FAILURE                            =           0x60000001, //操作因为某些不规范的原因失败
    VSG_FIDO_CANCELED                           =           0x60000002, //操作被用户取消
    VSG_FIDO_NO_MATCH                           =           0x60000003, //没有可用认证器
    VSG_FIDO_NOT_INSTALLED                      =           0x60000004, //MFAC 没有安装
    VSG_FIDO_NOT_COMPATIBLE                     =           0x60000005, //MFAC 不兼容
    VSG_FIDO_APP_NOT_FOUND                      =           0x60000006, //Facet 文件中没有该应用 id
    VSG_FIDO_TRANSACTION_ERROR                  =           0x60000007, //交易文本没有被执行(暂时不用，属于扩展)
    VSG_FIDO_WAIT_USER_ACTION                   =           0x60000008, //等待用户执行操作(暂时不用，属于 扩展)
    VSG_FIDO_INSECURE_TRANSPORT                 =           0x60000009, //暂时未用
    VSG_FIDO_PROTOCOL_ERROR                     =           0x60000010, //一个违反 UAF 协议的操作
    VSG_FIDO_TOUIDINVALID                       =           0x60000011, //手机上没有注册指纹
    VSG_FIDO_CRT_NOT_LEGAL                      =           0x60000012, //服务器证书不合法
    VSG_FIDO_DEVICE_STATUS_Normal               =           0x60000020, //可用
    VSG_FIDO_DEVICE_STATUS_Lock                 =           0x60000021, //设备锁死
    VSG_FIDO_DEVICE_STATUS_NotSupport           =           0x60000022, //没有指纹

};



#endif /* VSGMacro_h */
