class Api {



  ///浩海

  static const String HUAWEI_TEST = "http://121.36.68.43:10100/";//华为云测试地址
  // static const String HUAWEI_TEST = "http://111.41.48.160:1080/";//华为云测试地址
  static const String HEI_RELEASE = "http://124.70.70.170:10100/";//黑龙江正式地址
  static const String HAOHAI_RELEASE = "http://117.132.5.139:8011/";//公司地址
  static const String JM_RELEASE = "http://10.135.48.55:10100/";//即墨正式地址

  static const String HEI_PERMISSION = "http://124.70.70.170:10100/auth/";
  static const String JM_PERMISSION = "http://10.135.48.55:10100/auth/";
  static const String HAOHAI_PERMISSION = "http://117.132.5.139:8011/auth/";

  static const String REQUEST_PERMISSION = JM_PERMISSION;
  static const String REQUEST_BASE = JM_RELEASE;//HEI_RELEASE(内江)  HUAWEI_TEST(黑龙江)


  //登录
  static const String Login = REQUEST_BASE + "auth/oauth/token";
  //获取用户信息fileUploadAnByNotToken
  static const String UserInfo = REQUEST_BASE + "auth/api/auth/user/get/userinfo";
  //获取用户主页菜单
  static const String UserMainMenu = REQUEST_BASE + "auth/api/auth/auth/list/menu/by/user";
  //获取用户菜单
  static const String UserMenu = REQUEST_BASE + "auth/api/auth/auth/list/element/from/menuApp";
  //修改密码
  static const String ChangePassWord = REQUEST_BASE + "auth/api/auth/user/modfiy/passwd";
  //隐患排查
  static const String DangerCheck = REQUEST_BASE + "fire/api/dangerCheck";
  //调度任务列表
  static const String DispatcherTask = REQUEST_BASE + "oa/api/taskManagement/listNew";
  //统计
  static const String Statistics = REQUEST_BASE + "fire/api/monitorFirealarm/getFireAlarmByDis";
  //调度任务列表详情
  static const String DispatcherTaskDetail = REQUEST_BASE + "oa/api/taskManagement";
  //调度任务列表详情-现场上报图片
  static const String LiveUploadPic = REQUEST_BASE + "oa/api/workReport/fileUploadAn";
  //调度任务列表详情-现场上报视频 / （火情上报上传图片/上传视频）
  static const String LiveUploadVideo = REQUEST_BASE + "oa/api/workReport/fileUploadAnByNotToken";
  //APP-火情上报
  static const String FireUpload = REQUEST_BASE + "fire/api/reportFirealarm";
  //调度任务列表详情-现场上报保存
  static const String LiveUploadCommit = REQUEST_BASE + "oa//api/taskDetail";
  //主页视频监控-视频菜单(新版)
  static const String VideoLeftMenu = REQUEST_BASE + "resource/api/grid/listGridTreesNew";
  //主页视频监控-视频菜单-监控点(新版)
  static const String VideoLeftMenuPoint = REQUEST_BASE + "resource/api/monitor/getMonitorDetaisByGrid";
  //主页视频监控-视频菜单-监控点-摄像头(浩海)
  static const String VideoLeftMenuVideoHaohai = REQUEST_BASE + "resource/api/mediaKit/getStreamAndroid";
  //主页视频监控-视频菜单-监控点-摄像头(老版)
  static const String VideoLeftMenuVideoOld = REQUEST_BASE + "resource/api/guide/getVideo";
  //主页视频监控-视频菜单-监控点-摄像头(新版)
  static const String VideoLeftMenuVideo = REQUEST_BASE + "resource/api/liveVideo/getLiveVideo";
  //主页视频监控-视频菜单-监控点-摄像头控制
  static const String VideoControl = REQUEST_BASE + "resource/api/guide/yunTaiReverse";
  //主页视频监控-视频菜单-监控点-摄像头控制(浩海版本)
  static const String VideoControlHaoHai = REQUEST_BASE + "resource/api/liveVideo/control";
  //APP-火情上报-获取区域数据
  static const String AreaData = REQUEST_BASE + "auth/api/sysArea/getAllSysArea";
  //Map-火情列表
  static const String MapFireList = REQUEST_BASE + "fire/api/satelliteFirealarm/list";
  //Map-报警列表（一体机数据）
  static const String MapWarningList = REQUEST_BASE + "fire/api/monitorFirealarm/page";
  //Map-资源数据 -->动态获取
  static const String MapResourceData = REQUEST_BASE + "resource ??? /list";
  //Map-资源初始化数据
  static const String MapInitResourceData = REQUEST_BASE + "resource/api/resourceList/list";
  //Map-根据资源监控点id获取信息
  static const String MapResourceCameraDetail = REQUEST_BASE + "resource/api/camera/list";
  //上传用户位置
  static const String UploadUserLocation = REQUEST_BASE + "oa/api/trajectory/trackUpload";
  //从服务器获取阿启视token
  static const String GetAQSToken = REQUEST_BASE + "resource/api/aqishi/authentication";


  //版本检测
  static const String VersionInfo = REQUEST_PERMISSION + "api/androidUpgrade/getCurrent";






}